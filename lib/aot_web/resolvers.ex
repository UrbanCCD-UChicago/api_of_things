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

  @doc """
  It's the job of this function to convert `args` from a map to a list of tuples
  that follow this structure:

      iex> {:property, {:operator, "value"}}

  """
  defp format_args(args) do
    args
    |> Map.to_list()
    |> Enum.map(fn {column, comparison} ->
      [{operator, operand} | _] = Map.to_list(comparison)
      {column, {operator, operand}}
    end)
  end
end
