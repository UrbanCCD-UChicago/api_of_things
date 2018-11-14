defmodule AotWeb.NodeController do
  use AotWeb, :controller

  import AotWeb.ControllerUtils, only: [
    meta: 3,
    resp_format: 1
  ]

  import AotWeb.GenericPlugs

  import AotWeb.NodePlugs

  alias Aot.NodeActions

  action_fallback AotWeb.FallbackController

  plug :ensure_list, params: ~w(within_projects within_projects_exact has_sensors has_sensors_exact)
  plug :assign_if_exists, param: "include_projects", value_override: true
  plug :assign_if_exists, param: "include_sensors", value_override: true
  plug :assign_if_exists, param: "assert_alive", value_override: true
  plug :assign_if_exists, param: "assert_dead", value_override: true
  plug :assign_if_exists, param: "within_project"
  plug :assign_if_exists, param: "within_projects"
  plug :assign_if_exists, param: "within_projects_exact"
  plug :assign_if_exists, param: "has_sensor"
  plug :assign_if_exists, param: "has_sensors"
  plug :assign_if_exists, param: "has_sensors_exact"
  plug :timestamp, params: "commissioned_on"
  plug :timestamp, params: "decommissioned_on"
  plug :location
  plug :order, default: "asc:vsn", fields: ~W(vsn commissioned_on decommissioned_on)
  plug :paginate

  def index(conn, _params) do
    nodes = NodeActions.list(Map.to_list(conn.assigns))
    fmt = resp_format(conn)

    render conn, "index.json",
      nodes: nodes,
      resp_format: fmt,
      meta: meta(&node_url/3, :index, conn)
  end

  def show(conn, %{"id" => vsn}) do
    with {:ok, node} <- NodeActions.get(vsn, Map.to_list(conn.assigns))
    do
      render conn, "show.json",
        node: node,
        resp_format: resp_format(conn)
    end
  end
end
