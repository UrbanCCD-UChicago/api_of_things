defmodule AotWeb.ObservationView do
  use AotWeb, :view
  import AotWeb.ViewUtils
  alias AotWeb.ObservationView

  def render("index.json", %{observations: obs, format: format, meta: meta}) do
    %{data: render_many(obs, ObservationView, "observation.#{format}"), meta: meta}
  end

  def render("observation.json", %{observation: observation}) do
    if Map.has_key?(observation, :timestamp) do
      %{
        node_vsn: observation.node_vsn,
        sensor_path: observation.sensor_path,
        timestamp: observation.timestamp,
        value: observation.value,
        location: encode_geom(observation.location),
        uom: observation.uom
      }
    else
      observation
    end
  end

  def render("observation.geojson", %{observation: observation}) do
    %{
      type: "Feature",
      geometry: encode_geom(observation.location)[:geometry],
      properties: %{
        node_vsn: observation.node_vsn,
        sensor_path: observation.sensor_path,
        timestamp: observation.timestamp,
        value: observation.value,
        uom: observation.uom
      }
    }
  end
end
