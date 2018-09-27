defmodule AotWeb.RawObservationView do
  use AotWeb, :view
  alias AotWeb.RawObservationView

  def render("index.json", %{raw_observations: raw_observations}) do
    %{data: render_many(raw_observations, RawObservationView, "raw_observation.json")}
  end

  def render("show.json", %{raw_observation: raw_observation}) do
    %{data: render_one(raw_observation, RawObservationView, "raw_observation.json")}
  end

  def render("raw_observation.json", %{raw_observation: raw_observation}) do
    %{id: raw_observation.id,
      node: raw_observation.node,
      sensor: raw_observation.sensor,
      timestamp: raw_observation.timestamp,
      value: raw_observation.value}
  end
end
