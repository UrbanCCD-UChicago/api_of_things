defmodule AotWeb.SensorController do
  use AotWeb, :controller

  import AotWeb.GenericPlugs

  alias Aot.SensorActions

  action_fallback AotWeb.FallbackController

  plug :assign_if_exists, param: "include_networks", value_override: true
  plug :assign_if_exists, param: "include_nodes", value_override: true
  plug :assign_if_exists, param: "observes_network"
  plug :assign_if_exists, param: "observes_networks"
  plug :assign_if_exists, param: "observes_networks_exact"
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

  def show(conn, %{"id" => id}) do
    with {:ok, sensor} <- SensorActions.get(id, Map.to_list(conn.assigns))
    do
      render conn, "show.json",
        sensor: sensor
    end
  end
end
