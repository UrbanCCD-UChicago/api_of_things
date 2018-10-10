defmodule AotWeb.NodeController do
  use AotWeb, :controller

  import AotWeb.ControllerUtils, only: [
    resp_format: 1
  ]

  import AotWeb.GenericPlugs

  import AotWeb.NodePlugs

  alias Aot.NodeActions

  action_fallback AotWeb.FallbackController

  plug :assign_if_exists, param: "include_networks"
  plug :assign_if_exists, param: "include_sensors"
  plug :assign_if_exists, param: "assert_alive"
  plug :assign_if_exists, param: "assert_dead"
  plug :assign_if_exists, param: "within_network"
  plug :assign_if_exists, param: "within_networks"
  plug :assign_if_exists, param: "within_networks_exact"
  plug :assign_if_exists, param: "has_sensor"
  plug :assign_if_exists, param: "has_sensors"
  plug :assign_if_exists, param: "has_sensors_exact"
  plug :timestamp, params: "commissioned_on"
  plug :timestamp, params: "decommissioned_on"
  plug :location
  plug :order, default: "asc:id"
  plug :paginate

  def index(conn, _params) do
    nodes = NodeActions.list(Map.to_list(conn.assigns))
    fmt = resp_format(conn)

    render conn, "index.json",
      nodes: nodes,
      resp_format: fmt
  end

  def show(conn, %{"id" => id}) do
    with {:ok, node} <- NodeActions.get(id, Map.to_list(conn.assigns))
    do
      render conn, "show.json",
        node: node,
        resp_format: resp_format(conn)
    end
  end
end
