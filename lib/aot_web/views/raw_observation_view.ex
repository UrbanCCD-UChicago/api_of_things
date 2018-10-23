defmodule AotWeb.RawObservationView do
  use AotWeb, :view

  import AotWeb.ViewUtils

  alias AotWeb.RawObservationView

  def render("index.json", %{raw_observations: obs, meta: meta}) do
    %{meta: meta, data: render_many(obs, RawObservationView, "raw_observation.json")}
  end

  def render("show.json", %{raw_observation: obs}) do
    %{data: render_one(obs, RawObservationView, "raw_observation.json")}
  end

  def render("raw_observation.json", %{raw_observation: obs}) do
    case Map.has_key?(obs, :node_vsn) do
      true -> do_render(:obs, obs)
      false -> do_render(:agg, obs)
    end
  end

  defp do_render(:obs, obs) do
    %{
      node_vsn: obs.node_vsn,
      sensor_path: obs.sensor_path,
      timestamp: obs.timestamp,
      hrf: obs.hrf,
      raw: obs.raw,
    }
    |> nest_related(:node, obs.node, AotWeb.NodeView, "node.json", :one)
    |> nest_related(:sensor, obs.sensor, AotWeb.SensorView, "sensor.json", :one)
  end

  defp do_render(:agg, obs), do: obs
end
