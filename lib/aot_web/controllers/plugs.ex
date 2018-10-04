defmodule Aot.Plugs do
  @moduledoc """
  All common plugs should go in here. Anything specific to a controller
  should go in that controller's module.
  """

  import Aot.ControllerUtils, only: [ halt_with: 3 ]

  import Plug.Conn, only: [ assign: 3 ]

  alias Plug.Conn

  # PAGINATION

  @page_default 1
  @page_error "`page` must be a positive integer"

  def validate_page(%Conn{params: %{"page" => page}} = conn, _opts) when is_integer(page) and page > 0,
    do: conn

  def validate_page(%Conn{params: %{"page" => page}} = conn, _opts) when is_integer(page) and page <= 0,
    do: halt_with(conn, :unprocessable_entity, @page_error)

  def validate_page(%Conn{params: %{"page" => page}} = conn, opts) when is_bitstring(page) do
    try do
      page = String.to_integer(page)

      %Conn{conn | params: Map.put(conn.params, "page", page)}
      |> validate_page(opts)

    rescue
      ArgumentError ->
        halt_with(conn, :bad_request, @page_error)
    end
  end

  def validate_page(conn, opts) do
    %Conn{conn | params: Map.put(conn.params, "page", @page_default)}
    |> validate_page(opts)
  end

  @size_max 5_000
  @size_default 200
  @size_error "`size` must be a positive integer not exceeding #{@size_max}"

  def validate_size(%Conn{params: %{"size" => size}} = conn, _opts)
    when is_integer(size) and size > 0 and size <= @size_max,
    do: conn

  def validate_size(%Conn{params: %{"size" => size}} = conn, _opts) when is_integer(size),
    do: halt_with(conn, :unprocessable_entity, @size_error)

  def validate_size(%Conn{params: %{"size" => size}} = conn, opts) when is_bitstring(size) do
    try do
      size = String.to_integer(size)

      %Conn{conn | params: Map.put(conn.params, "size", size)}
      |> validate_size(opts)

    rescue
      ArgumentError ->
        halt_with(conn, :bad_request, @size_error)
    end
  end

  def validate_size(conn, opts) do
    %Conn{conn | params: Map.put(conn.params, "size", @size_default)}
    |> validate_size(opts)
  end

  def paginate(%Conn{params: %{"page" => page, "size" => size}} = conn, _opts),
    do: assign(conn, :paginate, {page, size})

  # ORDER BY

  @order_regex ~r/^asc|desc\:/i
  @order_error "`order_by` must follow format 'direction:field' where direction is either 'asc' or 'desc'"

  def order_by(%Conn{params: %{"order_by" => order}} = conn, _opts) when is_bitstring(order) do
    case Regex.match?(@order_regex, order) do
      false ->
        halt_with(conn, :bad_request, @order_error)

      true ->
        [dir, field] = String.split(order, ":", parts: 2)
        dir = String.downcase(dir)
        assign(conn, :order_by, {String.to_atom(dir), String.to_atom(field)})
    end
  end

  def order_by(conn, opts) do
    %Conn{conn | params: Map.put(conn.params, "order_by", opts[:default_order])}
    |> order_by(opts)
  end

  # PRELOAD NODES

  def include_nodes(%Conn{params: %{"include_nodes" => nodes?}} = conn, _opts),
    do: if nodes?, do: assign(conn, :include_nodes, true), else: conn

  def include_nodes(conn, _opts), do: conn

  # PRELOAD SENSORS

  def include_sensors(%Conn{params: %{"include_sensors" => sensors?}} = conn, _opts),
    do: if sensors?, do: assign(conn, :include_sensors, true), else: conn

  def include_sensors(conn, _opts), do: conn

  # PRELOAD NETWORKS

  def include_networks(%Conn{params: %{"include_networks" => networks?}} = conn, _opts),
    do: if networks?, do: assign(conn, :include_networks, true), else: conn

  def include_networks(conn, _opts), do: conn

  # RELATED RESTRICTIONS

  @doc """
  Generically parses a connection's parameters for related
  entity restrictions. This requires passing the query module
  function name in the opts.

  ## Example

    # will check for has_node and has_nodes[]
    plug for_related, func: :has_node
  """
  @spec for_related(Plug.Conn.t(), keyword()) :: Plug.Conn.t()
  def for_related(%Conn{params: params} = conn, opts) do
    func = opts[:func]
    func_str = Atom.to_string(func)

    case Map.has_key?(params, func_str) do
      true ->
        assign(conn, func, params[func_str])

      false ->
        func = String.to_atom("#{func}s[]")
        func_str = Atom.to_string(func)

        case Map.has_key?(params, func_str) do
          false ->
            conn

          true ->
            assign(conn, func, params[func_str])
        end
    end
  end

  # GEOM FILTERS

  @geom_filter_fmt_error "filtering geometry fields requires the format `function:geometry`"
  @geom_func_error "unknown geometry comparison function"
  @geom_json_error "cannot parse json from filter value"
  @geom_geojson_error "cannot parse geometry from filter value"
  @geom_distance_regex ~r/^\w+\:\{.*\}$/i

  @doc """
  Generically parses a connection's parameters for geometry
  comparisons. This requires passing the field and a map of
  GIS-to-API functions.

  ## Example

    # looks for "bbox" parameter
    plug :geom_fiels, field: "bbox", func_map: %{"contains" => :bbox_contains, "intersects" => :bbox_intersects}
  """
  @spec geom_field(Plug.Conn.t(), keyword()) :: Plug.Conn.t()
  def geom_field(%Conn{params: params} = conn, opts) do
    field = opts[:field]
    func_map = opts[:func_map]

    case Map.has_key?(params, field) do
      false ->
        conn

      true ->
        geojson =
          params[field]
          |> String.split(":", parts: 2)

        try do
          validate_func(geojson, func_map, conn)
        rescue
          MatchError ->
            halt_with(conn, :bad_request, @geom_filter_fmt_error)
        end
    end
  end

  defp validate_func([user_func, geojson?], func_map, conn) do
    case Map.has_key?(func_map, user_func) do
      true ->
        api_func = func_map[user_func]
        validate_geom(geojson?, api_func, conn)

      false ->
        halt_with(conn, :bad_request, @geom_func_error)
    end
  end

  defp validate_geom(geojson, api_func, conn) do
    case Regex.match?(@geom_distance_regex, geojson) do
      false ->
        do_validate_geom(nil, geojson, api_func, conn)

      true ->
        [distance, geojson] = String.split(geojson, ":", parts: 2)
        do_validate_geom(distance, geojson, api_func, conn)
    end
  end

  defp do_validate_geom(nil, geojson, api_func, conn) do
    try do
      geojson =
        geojson
        |> Poison.decode!()
        |> Geo.JSON.decode!()

      assign(conn, api_func, geojson)

    rescue
      Poison.SyntaxError ->
        halt_with(conn, :unprocessable_entity, @geom_json_error)

      Geo.JSON.Decoder.DecodeError ->
        halt_with(conn, :unprocessable_entity, @geom_geojson_error)
    end
  end

  defp do_validate_geom(distance, geojson, api_func, conn) do
    case Float.parse(distance) do
      :error ->
        halt_with(conn, :bad_request, "could not parse distance value")

      {distance, _} ->
        try do
          geojson =
            geojson
            |> Poison.decode!()
            |> Geo.JSON.decode!()

          assign(conn, api_func, {geojson, distance})

        rescue
          Poison.SyntaxError ->
            halt_with(conn, :unprocessable_entity, @geom_json_error)

          Geo.JSON.Decoder.DecodeError ->
            halt_with(conn, :unprocessable_entity, @geom_geojson_error)
        end
    end
  end

  # TIMESTAMP FILTERS

  @ts_ops ~W( between eq ge gt in le lt )
  @ts_error "could not parse timestamp comparison from parameters"

  def timestamp_op(%Conn{params: params} = conn, opts) do
    field = opts[:field]
    func = opts[:func]

    case Map.has_key?(params, field) do
      false ->
        conn

      true ->
        op_value =
          params[field]
          |> String.split(":", parts: 2)

        do_timestamp_op(op_value, func, conn)
    end
  end

  defp do_timestamp_op([op, value], func, conn) when op in @ts_ops, do: assign(conn, func, value)

  defp do_timestamp_op(_, _, conn), do: halt_with(conn, :bad_request, @ts_error)
end
