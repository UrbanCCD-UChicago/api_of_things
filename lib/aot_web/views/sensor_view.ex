defmodule AotWeb.SensorView do
  use AotWeb, :view
  alias AotWeb.SensorView

  def render("index.json", %{sensors: sensors}) do
    %{data: render_many(sensors, SensorView, "sensor.json")}
  end

  def render("show.json", %{sensor: sensor}) do
    %{data: render_one(sensor, SensorView, "sensor.json")}
  end

  def render("sensor.json", %{sensor: sensor}) do
    %{
      id: sensor.id,
      path: sensor.path,
      ontology: sensor.ontology,
      subsystem: sensor.subsystem,
      sensor: sensor.sensor,
      parameter: sensor.parameter,
      unit: sensor.unit
    }
  end
end
