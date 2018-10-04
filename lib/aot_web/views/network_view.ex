defmodule AotWeb.NetworkView do
  use AotWeb, :view
  alias AotWeb.NetworkView

  def render("index.json", %{networks: networks, resp_format: fmt}) do
    %{data: render_many(networks, NetworkView, "network.#{fmt}")}
  end

  def render("show.json", %{network: network, resp_format: fmt}) do
    %{data: render_one(network, NetworkView, "network.#{fmt}")}
  end

  def render("network.json", %{network: net}) do
    %{
      id: net.id,
      name: net.name,
      slug: net.slug,
      full_archive: net.archive_url,
      first_observation: net.first_observation,
      latest_observation: net.latest_observation,
      bbox: Geo.JSON.encode!(net.bbox),
      hull: Geo.JSON.encode!(net.hull)
    }
  end

  def render("network.geojson", %{network: net}) do
    %{
      type: "Feature",
      geometry: Geo.JSON.encode!(net.bbox),
      properties: %{
        id: net.id,
        name: net.name,
        slug: net.slug,
        full_archive: net.archive_url,
        first_observation: net.first_observation,
        latest_observation: net.latest_observation
      }
    }
  end
end
