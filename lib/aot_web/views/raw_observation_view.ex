defmodule AotWeb.RawObservationView do
  use AotWeb, :view

  import AotWeb.ViewUtils

  alias AotWeb.RawObservationView

  def render("index.json", %{raw_observations: obs}) do
    %{data: render_many(obs, RawObservationView, "raw_observation.json")}
  end

  def render("show.json", %{raw_observation: obs}) do
    %{data: render_one(obs, RawObservationView, "raw_observation.json")}
  end

  def render("raw_observation.json", %{raw_observation: obs}) do
    %{
      node: obs.node,
      sensor: obs.sensor,
      timestamp: obs.timestamp,
      hrf: obs.hrf,
      raw: obs.raw,
    }
    |> nest_related(:node, obs.node, AotWeb.NodeView, "node.json", :one)
    |> nest_related(:sensor, obs.sensor, AotWeb.SensorView, "sensor.json", :one)
  end
end
