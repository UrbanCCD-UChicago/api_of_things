defmodule AotWeb.NodeView do
  use AotWeb, :view
  import AotWeb.ViewUtils
  alias AotWeb.NodeView

  def render("index.json", %{nodes: nodes, format: format, meta: meta}) do
    %{data: render_many(nodes, NodeView, "node.#{format}"), meta: meta}
  end

  def render("show.json", %{node: node, format: format}) do
    %{data: render_one(node, NodeView, "node.#{format}")}
  end

  def render("node.json", %{node: node}) do
    %{
      vsn: node.vsn,
      location: encode_geom(node.location),
      description: node.description,
      address: node.address
    }
    |> nest_related(:sensors, node.sensors, AotWeb.SensorView, "sensor.json")
  end

  def render("node.geojson", %{node: node}) do
    %{
      type: "Feature",
      geometry: encode_geom(node.location)[:geometry],
      properties: %{
        vsn: node.vsn,
        description: node.description,
        address: node.address
      }
      |> nest_related(:sensors, node.sensors, AotWeb.SensorView, "sensor.json")
    }
  end
end
