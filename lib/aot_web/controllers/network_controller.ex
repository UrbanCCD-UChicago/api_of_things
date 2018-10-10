defmodule AotWeb.NetworkController do
  use AotWeb, :controller

  import AotWeb.ControllerUtils, only: [
    resp_format: 1
  ]

  import AotWeb.GenericPlugs

  import AotWeb.NetworkPlugs

  alias Aot.NetworkActions

  action_fallback AotWeb.FallbackController

  plug :assign_if_exists, param: "include_nodes"
  plug :assign_if_exists, param: "include_sensors"
  plug :assign_if_exists, param: "has_node"
  plug :assign_if_exists, param: "has_nodes"
  plug :assign_if_exists, param: "has_nodes_exact"
  plug :assign_if_exists, param: "has_sensor"
  plug :assign_if_exists, param: "has_sensors"
  plug :assign_if_exists, param: "has_sensors_exact"
  plug :bbox
  plug :order, default: "asc:name"
  plug :paginate

  def index(conn, _params) do
    networks = NetworkActions.list(Map.to_list(conn.assigns))
    fmt = resp_format(conn)

    render conn, "index.json",
      networks: networks,
      resp_format: fmt
  end

  def show(conn, %{"id" => slug}) do
    with {:ok, network} <- NetworkActions.get(slug, Map.to_list(conn.assigns))
    do
      render conn, "show.json",
        network: network,
        resp_format: resp_format(conn)
    end
  end
end
