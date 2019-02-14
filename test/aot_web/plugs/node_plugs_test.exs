defmodule AotWeb.NodePlugsTest do
  use AotWeb.ConnCase, async: true

  @tag add2ctx: :nodes
  test "with sensors", %{conn: conn, n004: node} do
    %{"data" => data} =
      conn
      |> get(Routes.node_path(conn, :show, node, with_sensors: "true"))
      |> json_response(:ok)

    assert is_map(data)
    assert Map.has_key?(data, "vsn")
    assert Map.has_key?(data, "location")
    assert Map.has_key?(data, "address")
    assert Map.has_key?(data, "description")
    assert Map.has_key?(data, "sensors")

    sensors = data["sensors"]
    assert is_list(sensors)
    assert length(sensors) == 24
  end
end
