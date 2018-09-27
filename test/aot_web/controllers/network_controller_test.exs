defmodule AotWeb.NetworkControllerTest do
  use AotWeb.ConnCase

  alias Aot.Meta
  alias Aot.Meta.Network

  @create_attrs %{bbox: "some bbox", hull: "some hull", name: "some name", num_observations: 42, num_raw_observations: 42, slug: "some slug"}
  @update_attrs %{bbox: "some updated bbox", hull: "some updated hull", name: "some updated name", num_observations: 43, num_raw_observations: 43, slug: "some updated slug"}
  @invalid_attrs %{bbox: nil, hull: nil, name: nil, num_observations: nil, num_raw_observations: nil, slug: nil}

  def fixture(:network) do
    {:ok, network} = Meta.create_network(@create_attrs)
    network
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all networks", %{conn: conn} do
      conn = get conn, network_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create network" do
    test "renders network when data is valid", %{conn: conn} do
      conn = post conn, network_path(conn, :create), network: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, network_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "bbox" => "some bbox",
        "hull" => "some hull",
        "name" => "some name",
        "num_observations" => 42,
        "num_raw_observations" => 42,
        "slug" => "some slug"}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, network_path(conn, :create), network: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update network" do
    setup [:create_network]

    test "renders network when data is valid", %{conn: conn, network: %Network{id: id} = network} do
      conn = put conn, network_path(conn, :update, network), network: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get conn, network_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "bbox" => "some updated bbox",
        "hull" => "some updated hull",
        "name" => "some updated name",
        "num_observations" => 43,
        "num_raw_observations" => 43,
        "slug" => "some updated slug"}
    end

    test "renders errors when data is invalid", %{conn: conn, network: network} do
      conn = put conn, network_path(conn, :update, network), network: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete network" do
    setup [:create_network]

    test "deletes chosen network", %{conn: conn, network: network} do
      conn = delete conn, network_path(conn, :delete, network)
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, network_path(conn, :show, network)
      end
    end
  end

  defp create_network(_) do
    network = fixture(:network)
    {:ok, network: network}
  end
end
