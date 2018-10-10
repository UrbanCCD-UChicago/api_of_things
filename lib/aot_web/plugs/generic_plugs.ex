defmodule AotWeb.GenericPlugs do
  @moduledoc """
  """

  import AotWeb.ControllerUtils, only: [
    halt_with: 3
  ]

  import Plug.Conn, only: [
    assign: 3
  ]

  alias Plug.Conn

  @doc """
  A generic little catch all that let's you configure an arbitrary
  plug to check for the existance of a parameter. If it is in the
  query params, the value is plucked out and assigned to the atomized
  parameter.

  Note, this does no error checking or sanitization of the values. If
  you need to be explicit, then write a plug to do it -- e.g. doing
  comparison operations where the parameter has a custom format other
  than `key=value`.

  ## Example

    plug :assign_if_exists, param: "include_nodes"
    plug :assign_if_exists, param: "include_sensors"
    plug :assign_if_exists, param: "has_node"
  """
  @spec assign_if_exists(Conn.t(), keyword()) :: Conn.t()
  def assign_if_exists(conn, opts) do
    param = opts[:param]
    case Map.get(conn.params, param) do
      nil ->
        conn

      value ->
        key = String.to_atom(param)
        assign(conn, key, value)
    end
  end

  @doc """
  Validates page number and size parameters and then applies
  them to the connection for use as pagination markers when
  building a query.
  """
  @spec paginate(Conn.t(), any()) :: Conn.t()
  def paginate(conn, opts) do
    conn =
      conn
      |> validate_page(opts)
      |> validate_size(opts)

    page = Map.get(conn.params, "page")
    size = Map.get(conn.params, "size")

    assign(conn, :paginate, {page, size})
  end

  @page_default 1
  @page_error "page must be a positive integer"

  defp validate_page(%Conn{params: %{"page" => p}} = conn, _opts) when is_integer(p) and p > 0,
    do: conn

  defp validate_page(%Conn{params: %{"page" => p}} = conn, _opts) when is_integer(p),
    do: halt_with(conn, :unprocessable_entity, @page_error)

  defp validate_page(%Conn{params: %{"page" => p}} = conn, opts) when is_binary(p) do
    try do
      page = String.to_integer(p)

      %Conn{conn | params: Map.put(conn.params, "page", page)}
      |> validate_page(opts)

    rescue
      ArgumentError ->
        halt_with(conn, :bad_request, @page_error)
    end
  end

  defp validate_page(conn, opts) do
    %Conn{conn | params: Map.put(conn.params, "page", @page_default)}
    |> validate_page(opts)
  end

  @size_default 200
  @size_max 5_000
  @size_error "size must be a positive integer not exceeding #{@size_max}"

  defp validate_size(%Conn{params: %{"size" => s}} = conn, _opts) when is_integer(s) and s <= @size_max and s > 0,
    do: conn

  defp validate_size(%Conn{params: %{"size" => s}} = conn, _opts) when is_integer(s),
    do: halt_with(conn, :unprocessable_entity, @size_error)

  defp validate_size(%Conn{params: %{"size" => s}} = conn, opts) when is_binary(s) do
    try do
      size = String.to_integer(s)

      %Conn{conn | params: Map.put(conn.params, "size", size)}
      |> validate_size(opts)

    rescue
      ArgumentError ->
        halt_with(conn, :bad_request, @size_error)
    end
  end

  defp validate_size(conn, opts) do
    %Conn{conn | params: Map.put(conn.params, "size", @size_default)}
    |> validate_size(opts)
  end

  @order_regex ~r/^asc|desc\:.+/i
  @order_error "order must follow `dir:field` format where `dir` is either 'asc' or 'desc'"

  @doc """
  Validates the format of a given ordering parameter and applies
  it to the connection. If an order is not specified, it will
  apply a default given in the plug assignment.

  ## Example

    plug :order, default: "desc:timestamp"
  """
  @spec order(Conn.t(), any()) :: Conn.t()
  def order(%Conn{params: %{"order" => order}} = conn, _opts) do
    case Regex.match?(@order_regex, order) do
      false ->
        halt_with(conn, :bad_request, @order_error)

      true ->
        [dir, field] = String.split(order, ":", parts: 2)
        assign(conn, :order, {String.to_atom(dir), String.to_atom(field)})
    end
  end

  def order(conn, opts) do
    %Conn{conn | params: Map.put(conn.params, "order", opts[:default])}
    |> order(opts)
  end

  @ts_regex ~r/^lt|le|eq|ge|gt\:.+/i
  @ts_error "filtering against timestamps must follow `operator:date-time` format"
  @ts_fmt "timestamps must be formatted: `YYYY-mm-ddTHH:MM:SS`"

  @doc """
  Parses query params for a given field and then validates the
  operator and timestamp before applying them to the connection.
  """
  def timestamp(conn, opts) do
    field = opts[:param]

    case Map.get(conn.params, field) do
      nil ->
        conn

      value ->
        Regex.match?(@ts_regex, value)
        |> do_timestamp(value, field, conn)
    end
  end

  defp do_timestamp(false, _, _, conn),
    do: halt_with(conn, :bad_request, @ts_error)

  defp do_timestamp(true, value, field, conn) do
    [op, iso?] = String.split(value, ":", parts: 2)

    case Timex.parse(iso?, "{ISOdate}T{ISOtime}") do
      {:error, _} ->
        halt_with(conn, :bad_request, @ts_fmt)

      {:ok, ts} ->
        key = String.to_atom(field)
        assign(conn, key, {String.to_atom(op), ts})
    end
  end
end
