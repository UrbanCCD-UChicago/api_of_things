# defmodule AotWeb.NodeControllerTest do
#   use AotWeb.ConnCase

#   alias Aot.Meta
#   alias Aot.Meta.Node

#   @create_attrs %{commissioned_on: ~N[2010-04-17 14:00:00.000000], decommissioned_on: ~N[2010-04-17 14:00:00.000000], description: "some description", human_address: "some human_address", id: "some id", location: "some location", vsn: "some vsn"}
#   @update_attrs %{commissioned_on: ~N[2011-05-18 15:01:01.000000], decommissioned_on: ~N[2011-05-18 15:01:01.000000], description: "some updated description", human_address: "some updated human_address", id: "some updated id", location: "some updated location", vsn: "some updated vsn"}
#   @invalid_attrs %{commissioned_on: nil, decommissioned_on: nil, description: nil, human_address: nil, id: nil, location: nil, vsn: nil}

#   def fixture(:node) do
#     {:ok, node} = Meta.create_node(@create_attrs)
#     node
#   end

#   setup %{conn: conn} do
#     {:ok, conn: put_req_header(conn, "accept", "application/json")}
#   end

#   describe "index" do
#     test "lists all nodes", %{conn: conn} do
#       conn = get conn, node_path(conn, :index)
#       assert json_response(conn, 200)["data"] == []
#     end
#   end

#   # describe "create node" do
#   #   test "renders node when data is valid", %{conn: conn} do
#   #     conn = post conn, node_path(conn, :create), node: @create_attrs
#   #     assert %{"id" => id} = json_response(conn, 201)["data"]

#   #     conn = get conn, node_path(conn, :show, id)
#   #     assert json_response(conn, 200)["data"] == %{
#   #       "id" => id,
#   #       "commissioned_on" => ~N[2010-04-17 14:00:00.000000],
#   #       "decommissioned_on" => ~N[2010-04-17 14:00:00.000000],
#   #       "description" => "some description",
#   #       "human_address" => "some human_address",
#   #       "id" => "some id",
#   #       "location" => "some location",
#   #       "vsn" => "some vsn"}
#   #   end

#   #   test "renders errors when data is invalid", %{conn: conn} do
#   #     conn = post conn, node_path(conn, :create), node: @invalid_attrs
#   #     assert json_response(conn, 422)["errors"] != %{}
#   #   end
#   # end

#   # describe "update node" do
#   #   setup [:create_node]

#   #   test "renders node when data is valid", %{conn: conn, node: %Node{id: id} = node} do
#   #     conn = put conn, node_path(conn, :update, node), node: @update_attrs
#   #     assert %{"id" => ^id} = json_response(conn, 200)["data"]

#   #     conn = get conn, node_path(conn, :show, id)
#   #     assert json_response(conn, 200)["data"] == %{
#   #       "id" => id,
#   #       "commissioned_on" => ~N[2011-05-18 15:01:01.000000],
#   #       "decommissioned_on" => ~N[2011-05-18 15:01:01.000000],
#   #       "description" => "some updated description",
#   #       "human_address" => "some updated human_address",
#   #       "id" => "some updated id",
#   #       "location" => "some updated location",
#   #       "vsn" => "some updated vsn"}
#   #   end

#   #   test "renders errors when data is invalid", %{conn: conn, node: node} do
#   #     conn = put conn, node_path(conn, :update, node), node: @invalid_attrs
#   #     assert json_response(conn, 422)["errors"] != %{}
#   #   end
#   # end

#   # describe "delete node" do
#   #   setup [:create_node]

#   #   test "deletes chosen node", %{conn: conn, node: node} do
#   #     conn = delete conn, node_path(conn, :delete, node)
#   #     assert response(conn, 204)
#   #     assert_error_sent 404, fn ->
#   #       get conn, node_path(conn, :show, node)
#   #     end
#   #   end
#   # end

#   defp create_node(_) do
#     node = fixture(:node)
#     {:ok, node: node}
#   end
# end
