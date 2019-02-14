defmodule AotWeb.SensorView do
  use AotWeb, :view
  alias AotWeb.SensorView

  def render("index.json", %{sensors: sensors, meta: meta}) do
    %{data: render_many(sensors, SensorView, "sensor.json"), meta: meta}
  end

  def render("show.json", %{sensor: sensor}) do
    %{data: render_one(sensor, SensorView, "sensor.json")}
  end

  def render("sensor.json", %{sensor: sensor}) do
    %{
      path: sensor.path,
      uom: sensor.uom,
      min: sensor.min,
      max: sensor.max,
      data_sheet: sensor.data_sheet
    }
  end
end
