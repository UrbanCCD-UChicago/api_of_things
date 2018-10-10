defmodule AotWeb.SensorView do
  use AotWeb, :view

  import AotWeb.ViewUtils

  alias AotWeb.SensorView

  def render("index.json", %{sensors: sensors}) do
    %{data: render_many(sensors, SensorView, "sensor.json")}
  end

  def render("show.json", %{sensor: sensor}) do
    %{data: render_one(sensor, SensorView, "sensor.json")}
  end

  def render("sensor.json", %{sensor: sensor}) do
    %{
      path: sensor.path,
      ontology: sensor.ontology,
      subsystem: sensor.subsystem,
      sensor: sensor.sensor,
      parameter: sensor.parameter,
      uom: sensor.uom,
      min: sensor.min,
      max: sensor.max,
      data_sheet: sensor.data_sheet
    }
    |> nest_related(:nodes, sensor.nodes, AotWeb.NodeView, "node.json")
    |> nest_related(:networks, sensor.networks, AotWeb.NetworkView, "network.json")
  end
end
