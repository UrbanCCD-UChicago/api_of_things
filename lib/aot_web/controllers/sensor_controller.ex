defmodule AotWeb.SensorController do
  @moduledoc ""

  use AotWeb, :controller
  import AotWeb.SharedPlugs
  import AotWeb.ControllerUtils, only: [build_meta: 3]
  alias Aot.Sensors

  action_fallback AotWeb.FallbackController

  plug :order, default: "asc:path", fields: ~w(path)
  plug :paginate

  def index(conn, _params) do
    sensors = Sensors.list_sensors()
    render conn, "index.json",
      sensors: sensors,
      meta: build_meta(&Routes.sensor_url/3, :index, conn)
  end

  def show(conn, %{"id" => id}) do
    with {:ok, sensor} <- Sensors.get_sensor(id)
    do
      render(conn, "show.json", sensor: sensor)
    end
  end
end
