defmodule AotWeb.Resolvers do
  def list_projects(_, _, _) do
    {:ok, Aot.ProjectActions.list()}
  end

  def list_nodes(_, _, _) do
    {:ok, Aot.NodeActions.list()}
  end

  def list_sensors(_, _, _) do
    {:ok, Aot.SensorActions.list()}
  end

  def list_observations(_, _, _) do
    {:ok, Aot.ObservationActions.list()}
  end
end
