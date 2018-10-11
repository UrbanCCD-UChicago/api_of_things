defmodule AotWeb.Testing.NodePlugsTest do
  use Aot.Testing.BaseCase
  use Aot.Testing.DataCase
  use AotWeb.Testing.ConnCase

  describe "location=within:" do
    test "a polygon", %{conn: conn} do
      poly =
        %Geo.Polygon{
          srid: 4326,
          coordinates: [[
            {-88, 42},
            {-88, 40},
            {-86, 40},
            {-86, 42},
            {-88, 42}
          ]]
        }
        |> Geo.JSON.encode!()
        |> Jason.encode!()

      conn
      |> get(node_path(conn, :index, location: "within:#{poly}"))
      |> json_response(:ok)
    end

    test "a bad value will 400", %{conn: conn} do
      conn
      |> get(node_path(conn, :index, location: "within:chicago"))
      |> json_response(:bad_request)
    end
  end

  describe "location=distance:" do
    test "meters and point", %{conn: conn} do
      pt =
        %Geo.Point{srid: 4326, coordinates: {-87, 41}}
        |> Geo.JSON.encode!()
        |> Jason.encode!()

      conn
      |> get(node_path(conn, :index, location: "distance:1000:#{pt}"))
      |> json_response(:ok)
    end

    test "missing meters will 400", %{conn: conn} do
      pt =
        %Geo.Point{srid: 4326, coordinates: {-87, 41}}
        |> Geo.JSON.encode!()
        |> Jason.encode!()

      conn
      |> get(node_path(conn, :index, location: "distance:#{pt}"))
      |> json_response(:bad_request)
    end

    test "missing point will 400", %{conn: conn} do
      conn
      |> get(node_path(conn, :index, location: "distance:1000"))
      |> json_response(:bad_request)
    end

    test "bad point will 400", %{conn: conn} do
      conn
      |> get(node_path(conn, :index, location: "distance:1000:here"))
      |> json_response(:bad_request)
    end
  end
end
