defmodule AotWeb.NetworkView do
  use AotWeb, :view

  import AotWeb.ViewUtils

  alias AotWeb.NetworkView

  def render("index.json", %{networks: networks, resp_format: fmt}) do
    %{data: render_many(networks, NetworkView, "network.#{fmt}")}
  end

  def render("show.json", %{network: network, resp_format: fmt}) do
    %{data: render_one(network, NetworkView, "network.#{fmt}")}
  end

  def render("network.json", %{network: net}) do
    %{
      name: net.name,
      slug: net.slug,
      archive_url: net.archive_url,
      first_observation: net.first_observation,
      latest_observation: net.latest_observation,
      bbox: encode_geom(net.bbox),
      hull: encode_geom(net.hull)
    }
    |> nest_related(:nodes, net.nodes, AotWeb.NodeView, "node.json")
    |> nest_related(:sensors, net.sensors, AotWeb.SensorView, "sensor.json")
  end

  def render("network.geojson", %{network: net}) do
    %{
      type: "Feature",
      geometry: encode_geom(net.bbox),
      properties: %{
        name: net.name,
        slug: net.slug,
        archive_url: net.archive_url,
        first_observation: net.first_observation,
        latest_observation: net.latest_observation
      }
      |> nest_related(:nodes, net.nodes, AotWeb.NodeView, "node.geojson")
      |> nest_related(:sensors, net.sensors, AotWeb.SensorView, "sensor.json")
    }
  end
end
