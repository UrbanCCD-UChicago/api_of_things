defmodule AotWeb.NodeView do
  use AotWeb, :view
  alias AotWeb.NodeView

  def render("index.json", %{nodes: nodes}) do
    %{data: render_many(nodes, NodeView, "node.json")}
  end

  def render("show.json", %{node: node}) do
    %{data: render_one(node, NodeView, "node.json")}
  end

  def render("node.json", %{node: node}) do
    %{id: node.id,
      id: node.id,
      vsn: node.vsn,
      location: node.location,
      human_address: node.human_address,
      description: node.description,
      commissioned_on: node.commissioned_on,
      decommissioned_on: node.decommissioned_on}
  end
end
