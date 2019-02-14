defmodule AotWeb.Resolvers do
  def list_projects(_, args, _) do
    {:ok, args
      |> format_args()
      |> Aot.Projects.list_projects()}
  end

  def list_nodes(_, args, _) do
    {:ok, args
      |> format_args()
      |> Aot.Nodes.list_nodes()}
  end

  def list_sensors(_, args, _) do
    {:ok, args
      |> format_args()
      |> Aot.Sensors.list_sensors()}
  end

  def list_observations(_, args, _) do
    {:ok, args
      |> format_args()
      |> Aot.Observations.list_observations()}
  end

  defp format_args(args) do
    args
    |> Map.to_list()
    |> Enum.map(&format_arg/1)
  end

  defp format_arg({:intersects, geojson}) do
    coordinates =
      geojson.coordinates
      |> List.first()
      |> Enum.map(&List.to_tuple/1)
    {:bbox_intersects, struct!(Geo.Polygon, %{geojson | coordinates: [coordinates]})}
  end

  defp format_arg({:contains, geojson}) do
    coordinate = List.to_tuple(geojson[:coordinates])
    {:bbox_contains, struct!(Geo.Point, %{geojson | coordinates: coordinate})}
  end

  defp format_arg({:within, geojson}) do
    coordinates =
      geojson.coordinates
      |> List.first()
      |> Enum.map(&List.to_tuple/1)
    {:located_within, struct!(Geo.Polygon, %{geojson | coordinates: [coordinates]})}
  end

  defp format_arg({:alive, true}) do
    {:assert_dead, true}
  end

  defp format_arg({:alive, false}) do
    {:assert_dead, true}
  end

  defp format_arg({column, %{like: string}}) do
    {column, string}
  end

  defp format_arg({column, comparison}) do
    [{operator, operand} | _] = Map.to_list(comparison)
    {column, {operator, operand}}
  end
end
