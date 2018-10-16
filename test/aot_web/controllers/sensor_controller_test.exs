defmodule AotWeb.Testing.SensorControllerTest do
  use Aot.Testing.BaseCase
  use Aot.Testing.DataCase
  use AotWeb.Testing.ConnCase

  describe "index" do
    test "response data should be an array of objects", %{conn: conn} do
      %{"data" => data} =
        conn
        |> get(sensor_path(conn, :index))
        |> json_response(:ok)

      assert is_list(data)

      data
      |> Enum.each(& assert is_map(&1))
    end
  end

  describe "show" do
    @tag add2ctx: :sensors
    test "response data should be a single object", %{conn: conn, h2s_concentration: sensor} do
      %{"data" => data} =
        conn
        |> get(sensor_path(conn, :show, sensor))
        |> json_response(:ok)

      assert is_map(data)
    end

    test "using an unknown path should 404", %{conn: conn} do
      conn
      |> get(sensor_path(conn, :show, "alphasense.atm_concentration.co"))
      |> json_response(:not_found)
    end
  end
end
