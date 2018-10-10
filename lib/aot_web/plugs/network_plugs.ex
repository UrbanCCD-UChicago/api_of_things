defmodule AotWeb.NetworkPlugs do

  import AotWeb.ControllerUtils, only: [
    decode_geojson: 1,
    halt_with: 3
  ]

  import Plug.Conn, only: [
    assign: 3
  ]

  alias Plug.Conn

  @bbox_regex ~r/^contains|intersects\:.+/i

  @bbox_fmt_error "filtering against bbox must follow `operator:geojson` format"

  @doc """
  Checks the query params for the existance of a `bbox` key. If
  the bbox key is given, it then checks the format to ensure a
  correct operator is given and parses the value into a geometry
  struct. If all of that succeeds, it then assigns the geometry
  value to a concatenated key of `bbox_op`.
  """
  @spec bbox(any(), any()) :: any()
  def bbox(%Conn{params: %{"bbox" => bbox}} = conn, _opts) do
    case Regex.match?(@bbox_regex, bbox) do
      false ->
        halt_with(conn, :bad_request, @bbox_fmt_error)

      true ->
        [op, geo_string] = String.split(bbox, ":", parts: 2)

        with {:ok, geo_map} <- Jason.decode(geo_string),
            {:ok, geojson} <- decode_geojson(geo_map)
        do
          key = String.to_atom("bbox_#{op}")
          assign(conn, key, geojson)

        else
          _ ->
            halt_with(conn, :bad_request, @bbox_fmt_error)
        end
    end
  end

  def bbox(conn, _opts), do: conn
end
