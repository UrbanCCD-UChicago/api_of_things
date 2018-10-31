defmodule AotWeb.Resolvers do

  @doc """
  Example of possible `args` value:

      iex> %{
      ...>   name: %{
      ...>     eq: "Chicago"
      ...>   }
      ...> }

  """
  def list_projects(_, args, _) do
    {:ok, args
      |> format_args()
      |> Aot.ProjectActions.list()}
  end

  def list_nodes(_, args, _) do
    {:ok, args
      |> format_args()
      |> Aot.NodeActions.list()}
  end

  def list_sensors(_, args, _) do
    {:ok, args
      |> format_args()
      |> Aot.SensorActions.list()}
  end

  def list_observations(_, args, _) do
    {:ok, args
      |> format_args()
      |> Aot.ObservationActions.list()}
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
    {:within, struct!(Geo.Polygon, geojson)}
  end

  defp format_arg({column, comparison}) do
    [{operator, operand} | _] = Map.to_list(comparison)
    {column, {operator, operand}}
  end
end
