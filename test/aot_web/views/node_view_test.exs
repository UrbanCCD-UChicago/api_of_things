defmodule AotWeb.NodeViewTest do
  use AotWeb.ConnCase, async: true

  @tag add2ctx: :nodes
  test "json view", %{conn: conn, n004: node} do
    %{"data" => data} =
        conn
        |> get(Routes.node_path(conn, :show, node))
        |> json_response(:ok)

      assert is_map(data)
      assert Map.has_key?(data, "vsn")
      assert Map.has_key?(data, "location")
      assert Map.has_key?(data, "address")
      assert Map.has_key?(data, "description")
  end

  @tag add2ctx: :nodes
  test "geojson view", %{conn: conn, n004: node} do
    %{"data" => data} =
        conn
        |> get(Routes.node_path(conn, :show, node, format: "geojson"))
        |> json_response(:ok)

      assert is_map(data)
      assert Map.has_key?(data, "type")
      assert Map.has_key?(data, "geometry")
      assert Map.has_key?(data, "properties")

      props = data["properties"]
      assert Map.has_key?(props, "vsn")
      assert Map.has_key?(props, "address")
      assert Map.has_key?(props, "description")
  end
end
