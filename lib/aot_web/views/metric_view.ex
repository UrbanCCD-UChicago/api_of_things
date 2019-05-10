defmodule AotWeb.MetricView do
  use AotWeb, :view
  import AotWeb.ViewUtils
  alias AotWeb.MetricView

  def render("index.json", %{metrics: obs, format: format, meta: meta}) do
    %{data: render_many(obs, MetricView, "metric.#{format}"), meta: meta}
  end

  def render("metric.json", %{metric: metric}) do
    if Map.has_key?(metric, :timestamp) do
      %{
        node_vsn: metric.node_vsn,
        sensor_path: metric.sensor_path,
        timestamp: metric.timestamp,
        value: metric.value,
        location: encode_geom(metric.location),
        uom: metric.uom
      }
    else
      metric
    end
  end

  def render("metric.geojson", %{metric: metric}) do
    %{
      type: "Feature",
      geometry: encode_geom(metric.location)[:geometry],
      properties: %{
        node_vsn: metric.node_vsn,
        sensor_path: metric.sensor_path,
        timestamp: metric.timestamp,
        value: metric.value,
        uom: metric.uom
      }
    }
  end
end
