defmodule AotWeb.MetricController do
  use AotWeb, :controller
  import AotWeb.{ObservationPlugs, SharedPlugs}
  import AotWeb.ControllerUtils, only: [build_meta: 3]
  alias Aot.Metrics

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
    metrics = Metrics.list_metrics(Map.to_list(conn.assigns))
    render conn, "index.json",
      metrics: metrics,
      format: conn.assigns[:format],
      meta: build_meta(&Routes.metric_url/3, :index, conn)
  end
end
