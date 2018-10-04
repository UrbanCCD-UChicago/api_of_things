defmodule AotWeb.RawObservationController do
  use AotWeb, :controller

  import Aot.Plugs

  import Plug.Conn, only: [ assign: 3 ]

  alias Aot.RawObservationActions

  alias Plug.Conn

  # controller specific plugs

  def obs_include_node(%Conn{params: %{"include_node" => nodes?}} = conn, _opts),
    do: if nodes?, do: assign(conn, :include_node, true), else: conn

  def obs_include_node(conn, _opts), do: conn

  def obs_include_sensor(%Conn{params: %{"include_sensor" => sensors?}} = conn, _opts),
    do: if sensors?, do: assign(conn, :include_sensors, true), else: conn

  def obs_include_sensor(conn, _opts), do: conn


  # inline plugs

  plug :obs_include_node
  plug :obs_include_sensor
  plug :include_networks
  plug :for_related, func: :for_network
  plug :for_related, func: :for_node
  plug :for_related, func: :for_sensor
  plug :geom_field, field: "location", func_map: %{"within" => :located_within, "proximity" => :within_distance}
  plug :timestamp_op, field: "timestamp", func: :timestamp_op
  plug :order_by, default: "desc:timestamp"
  plug :validate_page
  plug :validate_size
  plug :paginate

  def index(conn, _params) do
    observations = RawObservationActions.list(Map.to_list(conn.assigns))
    render(conn, "index.json", observations: observations)
  end
end
