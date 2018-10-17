defmodule AotWeb.RawObservationController do
  use AotWeb, :controller

  import AotWeb.GenericPlugs

  import AotWeb.NodePlugs, only: [
    location: 2
  ]

  import AotWeb.ObservationPlugs, only: [
    as_time_buckets: 2
  ]

  import AotWeb.RawObservationPlugs

  alias Aot.RawObservationActions

  plug :assign_if_exists, param: "embed_node", value_override: true
  plug :assign_if_exists, param: "embed_sensor", value_override: true
  plug :assign_if_exists, param: "of_project"
  plug :assign_if_exists, param: "of_projects"
  plug :assign_if_exists, param: "from_node"
  plug :assign_if_exists, param: "from_nodes"
  plug :assign_if_exists, param: "by_sensor"
  plug :assign_if_exists, param: "by_sensors"
  plug :location
  plug :timestamp, param: "timestamp"
  plug :compare, param: "raw"
  plug :compare, param: "hrf"
  plug :aggregates, groupers: ~W(node_vsn sensor_path)
  plug :as_histograms, groupers: ~W(node_vsn sensor_path)
  plug :as_time_buckets, groupers: ~W(node_vsn sensor_path)
  plug :order, default: "desc:timestamp", fields: ~W(timestamp node_vsn sensor_path)
  plug :paginate

  def index(conn, _params) do
    observations = RawObservationActions.list(Map.to_list(conn.assigns))
    render(conn, "index.json", raw_observations: observations)
  end
end
