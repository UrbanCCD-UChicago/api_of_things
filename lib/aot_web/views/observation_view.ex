defmodule AotWeb.ObservationView do
  use AotWeb, :view
  alias AotWeb.ObservationView

  def render("index.json", %{observations: observations}) do
    %{data: render_many(observations, ObservationView, "observation.json")}
  end

  def render("show.json", %{observation: observation}) do
    %{data: render_one(observation, ObservationView, "observation.json")}
  end

  def render("observation.json", %{observation: obs}) do
    %{
      node: obs.node,
      sensor: obs.sensor,
      timestamp: obs.timestamp,
      value: obs.value
    }
  end
end
