defmodule AotWeb.ObservationView do
  use AotWeb, :view
  alias AotWeb.ObservationView

  def render("index.json", %{observations: observations}) do
    %{data: render_many(observations, ObservationView, "observation.json")}
  end

  def render("show.json", %{observation: observation}) do
    %{data: render_one(observation, ObservationView, "observation.json")}
  end

  def render("observation.json", %{observation: observation}) do
    %{id: observation.id,
      node: observation.node,
      sensor: observation.sensor,
      timestamp: observation.timestamp,
      value: observation.value}
  end
end
