defmodule AotWeb.ObservationViewTest do
  use AotWeb.ConnCase, async: true

  test "json view", %{conn: conn} do
    %{"data" => data} =
        conn
        |> get(Routes.observation_path(conn, :index))
        |> json_response(:ok)

      assert is_list(data)
      Enum.each(data, fn record ->
        assert Map.has_key?(record, "node_vsn")
        assert Map.has_key?(record, "sensor_path")
        assert Map.has_key?(record, "value")
        assert Map.has_key?(record, "uom")
        assert Map.has_key?(record, "location")
      end)
  end

  @tag add2ctx: :nodes
  test "geojson view", %{conn: conn} do
    %{"data" => data} =
        conn
        |> get(Routes.observation_path(conn, :index, format: "geojson"))
        |> json_response(:ok)

      assert is_list(data)
      Enum.each(data, fn record ->
        assert Map.has_key?(record, "type")
        assert Map.has_key?(record, "geometry")
        assert Map.has_key?(record, "properties")

        props = record["properties"]
        assert Map.has_key?(props, "node_vsn")
        assert Map.has_key?(props, "sensor_path")
        assert Map.has_key?(props, "value")
        assert Map.has_key?(props, "uom")
      end)
  end
end
