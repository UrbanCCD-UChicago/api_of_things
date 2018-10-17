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
      value: obs.value
    }
    |> nest_related(:node, obs.node, AotWeb.NodeView, "node.json", :one)
    |> nest_related(:sensor, obs.sensor, AotWeb.SensorView, "sensor.json", :one)
  end

  defp do_render(:agg, obs), do: obs
end
