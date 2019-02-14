defmodule AotWeb.NodeController do
  use AotWeb, :controller
  import AotWeb.{NodePlugs, SharedPlugs}
  import AotWeb.ControllerUtils, only: [build_meta: 3]
  alias Aot.Nodes

  action_fallback AotWeb.FallbackController

  plug :with_sensors
  plug :for_project
  plug :located_within
  plug :located_dwithin
  plug :order, default: "asc:vsn", fields: ~w(vsn)
  plug :paginate
  plug :format

  def index(conn, _params) do
    nodes = Nodes.list_nodes(Map.to_list(conn.assigns))
    render conn, "index.json",
      nodes: nodes,
      format: conn.assigns[:format],
      meta: build_meta(&Routes.node_url/3, :index, conn)
  end

  def show(conn, %{"id" => id}) do
    with {:ok, node} <- Nodes.get_node(id, Map.to_list(conn.assigns))
    do
      render conn, "show.json",
        node: node,
        format: conn.assigns[:format]
    end
  end
end
