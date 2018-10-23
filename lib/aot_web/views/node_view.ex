defmodule AotWeb.NodeView do
  use AotWeb, :view

  import AotWeb.ViewUtils

  alias AotWeb.NodeView

  def render("index.json", %{nodes: nodes, resp_format: fmt, meta: meta}) do
    %{meta: meta, data: render_many(nodes, NodeView, "node.#{fmt}")}
  end

  def render("show.json", %{node: node, resp_format: fmt}) do
    %{data: render_one(node, NodeView, "node.#{fmt}")}
  end

  def render("node.json", %{node: node}) do
    %{
      vsn: node.vsn,
      location: encode_geom(node.location),
      description: node.description,
      address: node.address,
      commissioned_on: node.commissioned_on,
      decommissioned_on: node.decommissioned_on
    }
    |> nest_related(:projects, node.projects, AotWeb.ProjectView, "project.json")
    |> nest_related(:sensors, node.sensors, AotWeb.SensorView, "sensor.json")
  end

  def render("node.geojson", %{node: node}) do
    %{
      type: "Feature",
      geometry: encode_geom(node.location),
      properties: %{
        vsn: node.vsn,
        description: node.description,
        address: node.address,
        commissioned_on: node.commissioned_on,
        decommissioned_on: node.decommissioned_on
      }
      |> nest_related(:projects, node.projects, AotWeb.ProjectView, "project.geojson")
      |> nest_related(:sensors, node.sensors, AotWeb.SensorView, "sensor.json")
    }
  end
end
