defmodule AotWeb.SensorController do
  use AotWeb, :controller

  import AotWeb.GenericPlugs

  alias Aot.SensorActions

  action_fallback AotWeb.FallbackController

  plug :assign_if_exists, param: "include_projects", value_override: true
  plug :assign_if_exists, param: "include_nodes", value_override: true
  plug :assign_if_exists, param: "observes_project"
  plug :assign_if_exists, param: "observes_projects"
  plug :assign_if_exists, param: "observes_projects_exact"
  plug :assign_if_exists, param: "onboard_node"
  plug :assign_if_exists, param: "onboard_nodes"
  plug :assign_if_exists, param: "onboard_nodes_exact"
  plug :assign_if_exists, param: "ontology"
  plug :order, default: "asc:path", fields: ~W(path ontology subsystem sensor parameter)
  plug :paginate

  def index(conn, _params) do
    sensors = SensorActions.list(Map.to_list(conn.assigns))

    render conn, "index.json",
      sensors: sensors
  end

  def show(conn, %{"id" => path}) do
    with {:ok, sensor} <- SensorActions.get(path, Map.to_list(conn.assigns))
    do
      render conn, "show.json",
        sensor: sensor
    end
  end
end
