defmodule AotWeb.ObservationView do
  use AotWeb, :view

  import AotWeb.ViewUtils

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
    |> nest_related(:node, obs.node, AotWeb.NodeView, "node.json", :one)
    |> nest_related(:sensor, obs.sensor, AotWeb.SensorView, "sensor.json", :one)
  end
end
