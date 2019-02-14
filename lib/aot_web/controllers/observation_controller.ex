defmodule AotWeb.ObservationController do
  use AotWeb, :controller
  import AotWeb.{ObservationPlugs, SharedPlugs}
  import AotWeb.ControllerUtils, only: [build_meta: 3]
  alias Aot.Observations

  action_fallback AotWeb.FallbackController

  plug :for_node
  plug :for_sensor
  plug :for_project
  plug :located_within
  plug :located_dwithin
  plug :timestamp
  plug :value
  plug :histogram
  plug :time_bucket
  plug :order, default: "desc:timestamp", fields: ~w(node_vsn sensor_path timestamp value)
  plug :paginate
  plug :format

  def index(conn, _params) do
    observations = Observations.list_observations(Map.to_list(conn.assigns))
    render conn, "index.json",
      observations: observations,
      format: conn.assigns[:format],
      meta: build_meta(&Routes.observation_url/3, :index, conn)
  end
end
