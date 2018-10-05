defmodule AotWeb.NetworkController do
  use AotWeb, :controller

  import Aot.ControllerUtils, only: [ resp_format: 1 ]

  import Aot.Plugs

  alias Aot.NetworkActions

  action_fallback AotWeb.FallbackController

  plug :include_nodes
  plug :include_sensors
  plug :for_related, func: :has_node
  plug :for_related, func: :has_sensor
  plug :geom_field, field: "bbox", func_map: %{"contains" => :bbox_contains, "intersects" => :bbox_intersects}
  plug :geom_field, field: "hull", func_map: %{"contains" => :hull_contains, "intersects" => :hull_intersects}
  plug :order_by, default: "asc:name"
  plug :validate_page
  plug :validate_size
  plug :paginate

  def index(conn, _params) do
    networks = NetworkActions.list(Map.to_list(conn.assigns))
    fmt = resp_format(conn)

    render conn, "index.json",
      networks: networks,
      resp_format: fmt
  end

  def show(conn, %{"id" => slug}) do
    with {:ok, network} <- NetworkActions.get(slug, Map.to_list(conn.assigns)),
      do: render conn, "show.json", network: network, resp_format: resp_format(conn)
  end
end
