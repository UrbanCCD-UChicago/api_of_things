defmodule AotWeb.NodeController do
  use AotWeb, :controller

  import Aot.ControllerUtils, only: [ resp_format: 1 ]

  import Aot.Plugs

  import Plug.Conn, only: [ assign: 3 ]

  alias Aot.NodeActions

  alias Plug.Conn

  # controller specific plugs

  def node_assert_alive(%Conn{params: %{"only_alive" => alive?}} = conn, _opts),
    do: if alive?, do: assign(conn, :assert_alive, true), else: conn

  def node_assert_alive(conn, _opts), do: conn

  def node_assert_dead(%Conn{params: %{"only_dead" => dead?}} = conn, _opts),
    do: if dead?, do: assign(conn, :assert_dead, true), else: conn

  def node_assert_dead(conn, _opts), do: conn

  # inline plugs

  plug :include_networks
  plug :include_sensors
  plug :node_assert_alive
  plug :node_assert_dead
  plug :for_related, func: :within_network
  plug :for_related, func: :has_sensor
  plug :geom_field, field: "location", func_map: %{"within" => :located_within, "proximity" => :within_distance}
  plug :timestamp_op, field: "commissioned_on", func: :commissioned_on_op
  plug :timestamp_op, field: "decommissioned_on", func: :decommissioned_on_op
  plug :order_by, default: "asc:id"
  plug :validate_page
  plug :validate_size
  plug :paginate

  action_fallback AotWeb.FallbackController

  def index(conn, _params) do
    nodes = NodeActions.list(Map.to_list(conn.assigns))
    fmt = resp_format(conn)

    render conn, "index.json",
      nodes: nodes,
      resp_format: fmt
  end

  def show(conn, %{"id" => id}) do
    with {:ok, node} <- NodeActions.get(id, Map.to_list(conn.assigns)),
      do: render conn, "show.json", node: node, resp_format: resp_format(conn)
  end
end
