defmodule AotWeb.NetworkView do
  use AotWeb, :view
  alias AotWeb.NetworkView

  def render("index.json", %{networks: networks}) do
    %{data: render_many(networks, NetworkView, "network.json")}
  end

  def render("show.json", %{network: network}) do
    %{data: render_one(network, NetworkView, "network.json")}
  end

  def render("network.json", %{network: network}) do
    %{id: network.id,
      name: network.name,
      slug: network.slug,
      bbox: network.bbox,
      hull: network.hull,
      num_observations: network.num_observations,
      num_raw_observations: network.num_raw_observations}
  end
end
