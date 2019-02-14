defmodule AotWeb.SensorControllerTest do
  use AotWeb.ConnCase, async: true

  describe "show" do
    @tag add2ctx: [:projects, :sensors]
    test "an unknown slug will 404", %{conn: conn} do
      conn
      |> get(Routes.sensor_path(conn, :show, "dunno"))
      |> json_response(:not_found)
    end
  end
end
