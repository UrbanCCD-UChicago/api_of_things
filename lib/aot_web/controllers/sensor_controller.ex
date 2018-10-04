defmodule AotWeb.SensorController do
  use AotWeb, :controller

  import Aot.Plugs

  alias Aot.SensorActions

  action_fallback AotWeb.FallbackController

  plug :include_networks
  plug :include_nodes
  plug :for_related, func: :observes_network
  plug :for_related, func: :onboard_node
  plug :order_by, default: "asc:ontology"
  plug :validate_page
  plug :validate_size
  plug :paginate

  def index(conn, _params) do
    sensors = SensorActions.list(Map.to_list(conn.assigns))
    render(conn, "index.json", sensors: sensors)
  end

  def show(conn, %{"id" => id}) do
    sensor = SensorActions.get!(id, Map.to_list(conn.assigns))
    render(conn, "show.json", sensor: sensor)
  end
end
