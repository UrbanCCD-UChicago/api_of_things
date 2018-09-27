defmodule AotWeb.SensorController do
  use AotWeb, :controller

  alias Aot.Meta
  # alias Aot.Meta.Sensor

  # action_fallback AotWeb.FallbackController

  def index(conn, _params) do
    sensors = Meta.list_sensors()
    render(conn, "index.json", sensors: sensors)
  end

  def show(conn, %{"id" => id}) do
    sensor = Meta.get_sensor!(id)
    render(conn, "show.json", sensor: sensor)
  end

  # def create(conn, %{"sensor" => sensor_params}) do
  #   with {:ok, %Sensor{} = sensor} <- Meta.create_sensor(sensor_params) do
  #     conn
  #     |> put_status(:created)
  #     |> put_resp_header("location", sensor_path(conn, :show, sensor))
  #     |> render("show.json", sensor: sensor)
  #   end
  # end

  # def update(conn, %{"id" => id, "sensor" => sensor_params}) do
  #   sensor = Meta.get_sensor!(id)
  #
  #   with {:ok, %Sensor{} = sensor} <- Meta.update_sensor(sensor, sensor_params) do
  #     render(conn, "show.json", sensor: sensor)
  #   end
  # end

  # def delete(conn, %{"id" => id}) do
  #   sensor = Meta.get_sensor!(id)
  #   with {:ok, %Sensor{}} <- Meta.delete_sensor(sensor) do
  #     send_resp(conn, :no_content, "")
  #   end
  # end
end
