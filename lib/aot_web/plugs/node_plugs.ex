defmodule AotWeb.NodePlugs do

  import AotWeb.ControllerUtils, only: [
    decode_geojson: 1,
    halt_with: 3
  ]

  import Plug.Conn, only: [
    assign: 3
  ]

  alias Plug.Conn

  @loc_cont_regex ~r/^within\:.+/i

  @loc_dist_regex ~r/^distance\:\d+\:.+/i

  @loc_error "filtering against location must follow `within:geojson` or `distance:n:geojson` format"

  @doc """
  Parses a location query from the parameters and validates the
  operator, GeoJSON and meters (optional depending on if it's a
  distance query).
  """
  @spec location(Conn.t(), any()) :: Conn.t()
  def location(%Conn{params: %{"location" => loc}} = conn, _opts) do
    cond do
      Regex.match?(@loc_cont_regex, loc) ->
        contained(loc, conn)

      Regex.match?(@loc_dist_regex, loc) ->
        distance(loc, conn)

      true ->
        halt_with(conn, :bad_request, @loc_error)
    end
  end

  def location(conn, _opts), do: conn

  defp contained(loc, conn) do
    [_, geo_string] = String.split(loc, ":", parts: 2)

    with {:ok, geo_map} <- Jason.decode(geo_string),
         {:ok, geojson} <- decode_geojson(geo_map)
    do
      assign(conn, :located_within, geojson)

    else
      _ ->
        halt_with(conn, :bad_request, @loc_error)
    end
  end

  defp distance(loc, conn) do
    [_, meters, geo_string] = String.split(loc, ":", parts: 3)

    with {:ok, geo_map} <- Jason.decode(geo_string),
         {:ok, geojson} <- decode_geojson(geo_map),
         {:ok, meters} <- parse_meters(meters)
    do
      assign(conn, :located_within_distance, {meters, geojson})

    else
      _ ->
        halt_with(conn, :bad_request, @loc_error)
    end
  end

  defp parse_meters(meters) do
    try do
      value = String.to_integer(meters)
      {:ok, value}
    rescue
      ArgumentError ->
        {:error, nil}
    end
  end
end
