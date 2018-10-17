defmodule AotWeb.ObservationController do
  use AotWeb, :controller

  import AotWeb.GenericPlugs

  import AotWeb.ObservationPlugs

  import AotWeb.NodePlugs, only: [
    location: 2
  ]

  alias Aot.ObservationActions

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
  plug :value_funcs, groupers: ~W(node_id sensor_path)
  plug :as_histogram, groupers: ~W(node_id sensor_path)
  plug :as_time_buckets, groupers: ~W(node_id sensor_path)
  plug :order, default: "desc:timestamp", fields: ~W(timestamp node_id sensor_path)
  plug :paginate

  def index(conn, _params) do
    observations = ObservationActions.list(Map.to_list(conn.assigns))
    render(conn, "index.json", observations: observations)
  end
end
