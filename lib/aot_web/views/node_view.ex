defmodule AotWeb.NodeView do
  use AotWeb, :view

  import AotWeb.ViewUtils

  alias AotWeb.NodeView

  def render("index.json", %{nodes: nodes, resp_format: fmt}) do
    %{data: render_many(nodes, NodeView, "node.#{fmt}")}
  end

  def render("show.json", %{node: node, resp_format: fmt}) do
    %{data: render_one(node, NodeView, "node.#{fmt}")}
  end

  def render("node.json", %{node: node}) do
    %{
      id: node.id,
      vsn: node.vsn,
      location: encode_geom(node.location),
      description: node.description,
      address: node.address,
      commissioned_on: node.commissioned_on,
      decommissioned_on: node.decommissioned_on,
      networks: nest_related(node.networks, AotWeb.NetworkView, "network.json"),
      sensors: nest_related(node.sensors, AotWeb.SensorView, "sensor.json")
    }
  end

  def render("node.geojson", %{node: node}) do
    %{
      type: "Feature",
      geometry: encode_geom(node.location),
      properties: %{
        id: node.id,
        vsn: node.vsn,
        description: node.description,
        address: node.address,
        commissioned_on: node.commissioned_on,
        decommissioned_on: node.decommissioned_on,
        networks: nest_related(node.networks, AotWeb.NetworkView, "network.geojson"),
        sensors: nest_related(node.sensors, AotWeb.SensorView, "sensor.json")
      }
    }
  end
end
