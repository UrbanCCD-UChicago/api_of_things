defmodule AotWeb.Testing.ControllerUtilsTest do
  use Aot.Testing.BaseCase
  use Aot.Testing.DataCase
  use AotWeb.Testing.ConnCase

  describe "format" do
    test "if no format is given, the response is regular JSON", %{conn: conn} do
      %{"data" => data} =
        conn
        |> get(network_path(conn, :index))
        |> json_response(:ok)

      assert is_list(data)

      data
      |> Enum.each(& assert is_map(&1))
    end

    test "if `geojson` is given, the response is that", %{conn: conn} do
      %{"data" => data} =
        conn
        |> get(network_path(conn, :index, format: "geojson"))
        |> json_response(:ok)

      assert is_list(data)

      data
      |> Enum.each(fn obj ->
        assert is_map(obj)
        assert Map.has_key?(obj, "type")
        assert Map.has_key?(obj, "geometry")
        assert Map.has_key?(obj, "properties")
      end)
    end
  end
end
