defmodule AotWeb.SharedPlugs do
  @moduledoc false

  import AotWeb.ControllerUtils
  import Plug.Conn, only: [assign: 3]
  alias Plug.Conn

  @doc false
  def for_node(%Conn{params: %{"node" => vsn}} = conn, _) when is_binary(vsn), do: assign(conn, :for_node, vsn)
  def for_node(%Conn{params: %{"node" => vsns}} = conn, _) when is_list(vsns), do: assign(conn, :for_nodes, vsns)
  def for_node(conn, _), do: conn

  @doc false
  def for_sensor(%Conn{params: %{"sensor" => path}} = conn, _) when is_binary(path), do: assign(conn, :for_sensor, path)
  def for_sensor(%Conn{params: %{"sensor" => paths}} = conn, _) when is_list(paths), do: assign(conn, :for_sensors, paths)
  def for_sensor(conn, _), do: conn

  @doc false
  def for_project(%Conn{params: %{"project" => slug}} = conn, _), do: assign(conn, :for_project, slug)
  def for_project(conn, _), do: conn

  @doc false
  def format(%Conn{params: %{"format" => "geojson"}} = conn, _), do: assign(conn, :format, :geojson)
  def format(%Conn{params: %{"format" => "json"}} = conn, _), do: assign(conn, :format, :json)
  def format(%Conn{params: %{"format" => _}} = conn, _), do: halt_with(conn, 422)
  def format(conn, _), do: assign(conn, :format, :json)

  ##
  # geom plugs

  defp decode_geojson(%{"geometry" => %{"type" => _, "coordinates" => _} = geom}), do: Geo.JSON.decode(geom)
  defp decode_geojson(%{"type" => _, "coordinates" => _} = geom), do: Geo.JSON.decode(geom)
  defp decode_geojson(_), do: {:error, nil}

  @doc false
  def located_within(%Conn{params: %{"located_within" => geojson_string}} = conn, _) do
    Jason.decode!(geojson_string)
    |> decode_geojson()
    |> do_located_within(conn)
  end

  def located_within(conn, _), do: conn

  defp do_located_within({:ok, geom}, conn), do: assign(conn, :located_within, geom)
  defp do_located_within({:error, _}, conn), do: halt_with(conn, 400)

  @doc false
  def located_dwithin(%Conn{params: %{"located_dwithin" => dgeom}} = conn, _) do
    {distance, geom} =
      String.split(dgeom, ":", parts: 2)
      |> parse_distance(conn)
      |> parse_geojson_string(conn)

    assign(conn, :located_dwithin, [distance, geom])
  end

  def located_dwithin(conn, _), do: conn

  defp parse_distance([distance, geojson_string], conn) do
    case Float.parse(distance) do
      :error -> halt_with(conn, 400)
      {d, _} -> {d, geojson_string}
    end
  end

  defp parse_geojson_string({distance, geojson_string}, conn) do
    g = Jason.decode!(geojson_string) |> decode_geojson()
    case g do
      {:error, _} -> halt_with(conn, 400)
      {:ok, geom} -> {distance, geom}
    end
  end

  ##
  # pagination plug

  def paginate(conn, _) do
    if is_nil(conn.assigns[:histogram]) and is_nil(conn.assigns[:time_bucket]) do
      conn =
        conn
        |> validate_page()
        |> validate_size()

      assign(conn, :paginate, [conn.assigns[:page], conn.assigns[:size]])
    else
      conn
    end
  end

  defp validate_page(%Conn{params: %{"page" => p}} = conn) when is_integer(p) and p > 0, do: assign(conn, :page, p)
  defp validate_page(%Conn{params: %{"page" => p}} = conn) when is_integer(p), do: halt_with(conn, 422)
  defp validate_page(%Conn{params: %{"page" => p}} = conn) when is_binary(p) do
    try do
      page = String.to_integer(p)
      assign(conn, :page, page)
    rescue
      ArgumentError ->
        halt_with(conn, 400)
    end
  end

  defp validate_page(conn), do: %Conn{conn | params: Map.put(conn.params, "page", 1)} |> validate_page()

  defp validate_size(%Conn{params: %{"size" => s}} = conn) when is_integer(s) and s <= 5_000 and s > 0, do: assign(conn, :size, s)
  defp validate_size(%Conn{params: %{"size" => s}} = conn) when is_integer(s), do: halt_with(conn, 422)
  defp validate_size(%Conn{params: %{"size" => s}} = conn) when is_binary(s) do
    try do
      size = String.to_integer(s)
      assign(conn, :size, size)
    rescue
      ArgumentError ->
        halt_with(conn, 400)
    end
  end

  defp validate_size(conn), do: %Conn{conn | params: Map.put(conn.params, "size", 200)} |> validate_size()

  ##
  # order plug

  def order(%Conn{params: %{"order" => order}} = conn, opts) do
    if is_nil(conn.assigns[:histogram]) and is_nil(conn.assigns[:time_bucket]) do
      {direction, field_name} =
        String.split(order, ":", parts: 2)
        |> validate_direction(conn)
        |> validate_field_name(conn, opts[:fields])

      assign(conn, :order, [direction, field_name])
    else
      conn
    end
  end

  def order(conn, opts), do: %Conn{conn | params: Map.put(conn.params, "order", opts[:default])} |> order(opts)

  defp validate_direction([dir, fname], conn) do
    case Enum.member?(~w(asc desc), dir) do
      true -> [dir, fname]
      false -> halt_with(conn, 400)
    end
  end

  defp validate_field_name([dir, fname], conn, valid_fields) do
    case Enum.member?(valid_fields, fname) do
      true -> {dir, fname}
      false -> halt_with(conn, 422)
    end
  end
end
