defmodule AotWeb.NodeController do
  use AotWeb, :controller

  alias Aot.Meta
  # alias Aot.Meta.Node

  # action_fallback AotWeb.FallbackController

  def index(conn, _params) do
    nodes = Meta.list_nodes()
    render(conn, "index.json", nodes: nodes)
  end

  def show(conn, %{"id" => id}) do
    node = Meta.get_node!(id)
    render(conn, "show.json", node: node)
  end

  # def create(conn, %{"node" => node_params}) do
  #   with {:ok, %Node{} = node} <- Meta.create_node(node_params) do
  #     conn
  #     |> put_status(:created)
  #     |> put_resp_header("location", node_path(conn, :show, node))
  #     |> render("show.json", node: node)
  #   end
  # end

  # def update(conn, %{"id" => id, "node" => node_params}) do
  #   node = Meta.get_node!(id)
  #
  #   with {:ok, %Node{} = node} <- Meta.update_node(node, node_params) do
  #     render(conn, "show.json", node: node)
  #   end
  # end

  # def delete(conn, %{"id" => id}) do
  #   node = Meta.get_node!(id)
  #   with {:ok, %Node{}} <- Meta.delete_node(node) do
  #     send_resp(conn, :no_content, "")
  #   end
  # end
end
