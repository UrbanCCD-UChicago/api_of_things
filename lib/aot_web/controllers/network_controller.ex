defmodule AotWeb.NetworkController do
  use AotWeb, :controller

  alias Aot.Meta
  alias Aot.Meta.Network

  action_fallback AotWeb.FallbackController

  def index(conn, _params) do
    networks = Meta.list_networks()
    render(conn, "index.json", networks: networks)
  end

  def create(conn, %{"network" => network_params}) do
    with {:ok, %Network{} = network} <- Meta.create_network(network_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", network_path(conn, :show, network))
      |> render("show.json", network: network)
    end
  end

  def show(conn, %{"id" => id}) do
    network = Meta.get_network!(id)
    render(conn, "show.json", network: network)
  end

  def update(conn, %{"id" => id, "network" => network_params}) do
    network = Meta.get_network!(id)

    with {:ok, %Network{} = network} <- Meta.update_network(network, network_params) do
      render(conn, "show.json", network: network)
    end
  end

  # def delete(conn, %{"id" => id}) do
  #   network = Meta.get_network!(id)

  #   with {:ok, %Network{}} <- Meta.delete_network(network) do
  #     send_resp(conn, :no_content, "")
  #   end
  # end
end
