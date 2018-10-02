# defmodule AotWeb.SensorControllerTest do
#   use AotWeb.ConnCase

#   alias Aot.Meta
#   alias Aot.Meta.Sensor

#   @create_attrs %{max_val: 120.5, min_val: 120.5, ontology: "some ontology", parameter: "some parameter", sensor: "some sensor", subsystem: "some subsystem", unit: "some unit"}
#   @update_attrs %{max_val: 456.7, min_val: 456.7, ontology: "some updated ontology", parameter: "some updated parameter", sensor: "some updated sensor", subsystem: "some updated subsystem", unit: "some updated unit"}
#   @invalid_attrs %{max_val: nil, min_val: nil, ontology: nil, parameter: nil, sensor: nil, subsystem: nil, unit: nil}

#   def fixture(:sensor) do
#     {:ok, sensor} = Meta.create_sensor(@create_attrs)
#     sensor
#   end

#   setup %{conn: conn} do
#     {:ok, conn: put_req_header(conn, "accept", "application/json")}
#   end

#   describe "index" do
#     test "lists all sensors", %{conn: conn} do
#       conn = get conn, sensor_path(conn, :index)
#       assert json_response(conn, 200)["data"] == []
#     end
#   end

#   # describe "create sensor" do
#   #   test "renders sensor when data is valid", %{conn: conn} do
#   #     conn = post conn, sensor_path(conn, :create), sensor: @create_attrs
#   #     assert %{"id" => id} = json_response(conn, 201)["data"]

#   #     conn = get conn, sensor_path(conn, :show, id)
#   #     assert json_response(conn, 200)["data"] == %{
#   #       "id" => id,
#   #       "max_val" => 120.5,
#   #       "min_val" => 120.5,
#   #       "ontology" => "some ontology",
#   #       "parameter" => "some parameter",
#   #       "sensor" => "some sensor",
#   #       "subsystem" => "some subsystem",
#   #       "unit" => "some unit"}
#   #   end

#   #   test "renders errors when data is invalid", %{conn: conn} do
#   #     conn = post conn, sensor_path(conn, :create), sensor: @invalid_attrs
#   #     assert json_response(conn, 422)["errors"] != %{}
#   #   end
#   # end

#   # describe "update sensor" do
#   #   setup [:create_sensor]

#   #   test "renders sensor when data is valid", %{conn: conn, sensor: %Sensor{id: id} = sensor} do
#   #     conn = put conn, sensor_path(conn, :update, sensor), sensor: @update_attrs
#   #     assert %{"id" => ^id} = json_response(conn, 200)["data"]

#   #     conn = get conn, sensor_path(conn, :show, id)
#   #     assert json_response(conn, 200)["data"] == %{
#   #       "id" => id,
#   #       "max_val" => 456.7,
#   #       "min_val" => 456.7,
#   #       "ontology" => "some updated ontology",
#   #       "parameter" => "some updated parameter",
#   #       "sensor" => "some updated sensor",
#   #       "subsystem" => "some updated subsystem",
#   #       "unit" => "some updated unit"}
#   #   end

#   #   test "renders errors when data is invalid", %{conn: conn, sensor: sensor} do
#   #     conn = put conn, sensor_path(conn, :update, sensor), sensor: @invalid_attrs
#   #     assert json_response(conn, 422)["errors"] != %{}
#   #   end
#   # end

#   # describe "delete sensor" do
#   #   setup [:create_sensor]

#   #   test "deletes chosen sensor", %{conn: conn, sensor: sensor} do
#   #     conn = delete conn, sensor_path(conn, :delete, sensor)
#   #     assert response(conn, 204)
#   #     assert_error_sent 404, fn ->
#   #       get conn, sensor_path(conn, :show, sensor)
#   #     end
#   #   end
#   # end

#   defp create_sensor(_) do
#     sensor = fixture(:sensor)
#     {:ok, sensor: sensor}
#   end
# end
