defmodule AotWeb.ObservationController do
  use AotWeb, :controller

  import AotWeb.GenericPlugs

  import AotWeb.ObservationPlugs

  import AotWeb.NodePlugs, only: [
    location: 2
  ]

  alias Aot.ObservationActions

  plug :assign_if_exists, param: "embed_node"
  plug :assign_if_exists, param: "embed_sensor"
  plug :assign_if_exists, param: "of_network"
  plug :assign_if_exists, param: "of_networks"
  plug :assign_if_exists, param: "from_node"
  plug :assign_if_exists, param: "from_nodes"
  plug :assign_if_exists, param: "by_sensor"
  plug :assign_if_exists, param: "by_sensors"
  plug :location
  plug :timestamp, param: "timestamp"
  plug :value_funcs, param: "value"
  plug :as_histogram
  plug :as_time_buckets
  plug :order, default: "desc:timestamp"
  plug :paginate

  def index(conn, _params) do
    observations = ObservationActions.list(Map.to_list(conn.assigns))
    render(conn, "index.json", observations: observations)
  end
end
