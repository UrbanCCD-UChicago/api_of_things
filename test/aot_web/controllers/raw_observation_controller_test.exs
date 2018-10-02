# defmodule AotWeb.RawObservationControllerTest do
#   use AotWeb.ConnCase

#   alias Aot.Data
#   alias Aot.Data.RawObservation

#   @create_attrs %{node: "some node", sensor: "some sensor", timestamp: ~N[2010-04-17 14:00:00.000000], value: 120.5}
#   @update_attrs %{node: "some updated node", sensor: "some updated sensor", timestamp: ~N[2011-05-18 15:01:01.000000], value: 456.7}
#   @invalid_attrs %{node: nil, sensor: nil, timestamp: nil, value: nil}

#   def fixture(:raw_observation) do
#     {:ok, raw_observation} = Data.create_raw_observation(@create_attrs)
#     raw_observation
#   end

#   setup %{conn: conn} do
#     {:ok, conn: put_req_header(conn, "accept", "application/json")}
#   end

#   describe "index" do
#     test "lists all raw_observations", %{conn: conn} do
#       conn = get conn, raw_observation_path(conn, :index)
#       assert json_response(conn, 200)["data"] == []
#     end
#   end

#   # describe "create raw_observation" do
#   #   test "renders raw_observation when data is valid", %{conn: conn} do
#   #     conn = post conn, raw_observation_path(conn, :create), raw_observation: @create_attrs
#   #     assert %{"id" => id} = json_response(conn, 201)["data"]

#   #     conn = get conn, raw_observation_path(conn, :show, id)
#   #     assert json_response(conn, 200)["data"] == %{
#   #       "id" => id,
#   #       "node" => "some node",
#   #       "sensor" => "some sensor",
#   #       "timestamp" => ~N[2010-04-17 14:00:00.000000],
#   #       "value" => 120.5}
#   #   end

#   #   test "renders errors when data is invalid", %{conn: conn} do
#   #     conn = post conn, raw_observation_path(conn, :create), raw_observation: @invalid_attrs
#   #     assert json_response(conn, 422)["errors"] != %{}
#   #   end
#   # end

#   # describe "update raw_observation" do
#   #   setup [:create_raw_observation]

#   #   test "renders raw_observation when data is valid", %{conn: conn, raw_observation: %RawObservation{id: id} = raw_observation} do
#   #     conn = put conn, raw_observation_path(conn, :update, raw_observation), raw_observation: @update_attrs
#   #     assert %{"id" => ^id} = json_response(conn, 200)["data"]

#   #     conn = get conn, raw_observation_path(conn, :show, id)
#   #     assert json_response(conn, 200)["data"] == %{
#   #       "id" => id,
#   #       "node" => "some updated node",
#   #       "sensor" => "some updated sensor",
#   #       "timestamp" => ~N[2011-05-18 15:01:01.000000],
#   #       "value" => 456.7}
#   #   end

#   #   test "renders errors when data is invalid", %{conn: conn, raw_observation: raw_observation} do
#   #     conn = put conn, raw_observation_path(conn, :update, raw_observation), raw_observation: @invalid_attrs
#   #     assert json_response(conn, 422)["errors"] != %{}
#   #   end
#   # end

#   # describe "delete raw_observation" do
#   #   setup [:create_raw_observation]

#   #   test "deletes chosen raw_observation", %{conn: conn, raw_observation: raw_observation} do
#   #     conn = delete conn, raw_observation_path(conn, :delete, raw_observation)
#   #     assert response(conn, 204)
#   #     assert_error_sent 404, fn ->
#   #       get conn, raw_observation_path(conn, :show, raw_observation)
#   #     end
#   #   end
#   # end

#   defp create_raw_observation(_) do
#     raw_observation = fixture(:raw_observation)
#     {:ok, raw_observation: raw_observation}
#   end
# end
