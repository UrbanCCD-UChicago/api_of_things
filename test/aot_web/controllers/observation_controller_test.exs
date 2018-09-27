defmodule AotWeb.ObservationControllerTest do
  use AotWeb.ConnCase

  alias Aot.Data
  alias Aot.Data.Observation

  @create_attrs %{node: "some node", sensor: "some sensor", timestamp: ~N[2010-04-17 14:00:00.000000], value: 120.5}
  @update_attrs %{node: "some updated node", sensor: "some updated sensor", timestamp: ~N[2011-05-18 15:01:01.000000], value: 456.7}
  @invalid_attrs %{node: nil, sensor: nil, timestamp: nil, value: nil}

  def fixture(:observation) do
    {:ok, observation} = Data.create_observation(@create_attrs)
    observation
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all observations", %{conn: conn} do
      conn = get conn, observation_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create observation" do
    test "renders observation when data is valid", %{conn: conn} do
      conn = post conn, observation_path(conn, :create), observation: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, observation_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "node" => "some node",
        "sensor" => "some sensor",
        "timestamp" => ~N[2010-04-17 14:00:00.000000],
        "value" => 120.5}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, observation_path(conn, :create), observation: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update observation" do
    setup [:create_observation]

    test "renders observation when data is valid", %{conn: conn, observation: %Observation{id: id} = observation} do
      conn = put conn, observation_path(conn, :update, observation), observation: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get conn, observation_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "node" => "some updated node",
        "sensor" => "some updated sensor",
        "timestamp" => ~N[2011-05-18 15:01:01.000000],
        "value" => 456.7}
    end

    test "renders errors when data is invalid", %{conn: conn, observation: observation} do
      conn = put conn, observation_path(conn, :update, observation), observation: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete observation" do
    setup [:create_observation]

    test "deletes chosen observation", %{conn: conn, observation: observation} do
      conn = delete conn, observation_path(conn, :delete, observation)
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, observation_path(conn, :show, observation)
      end
    end
  end

  defp create_observation(_) do
    observation = fixture(:observation)
    {:ok, observation: observation}
  end
end
