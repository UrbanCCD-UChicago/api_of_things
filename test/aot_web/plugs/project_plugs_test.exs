defmodule AotWeb.Testing.ProjectPlugsTest do
  use Aot.Testing.BaseCase
  use Aot.Testing.DataCase
  use AotWeb.Testing.ConnCase

  describe "bbox=contains:" do
    test "a point", %{conn: conn} do
      pt = %Geo.Point{srid: 4326, coordinates: {-87, 41}}

      full_geojson =
        %{
          type: "Feature",
          geometry: Geo.JSON.encode!(pt)
        }
        |> Jason.encode!()

      conn
      |> get(project_path(conn, :index, bbox: "contains:#{full_geojson}"))
      |> json_response(:ok)

      geom_only =
        Geo.JSON.encode!(pt)
        |> Jason.encode!()

      conn
      |> get(project_path(conn, :index, bbox: "contains:#{geom_only}"))
      |> json_response(:ok)
    end

    test "a bad value will 400", %{conn: conn} do
      conn
      |> get(project_path(conn, :index, bbox: "contains:illinois"))
      |> json_response(:bad_request)
    end
  end

  describe "bbox=intersects:" do
    test "a polygon", %{conn: conn} do
      poly = %Geo.Polygon{
        srid: 4326,
        coordinates: [[
          {-88, 42},
          {-88, 40},
          {-86, 40},
          {-86, 42},
          {-88, 42}
        ]]
      }

      full_geojson =
        %{
          type: "Feature",
          geometry: Geo.JSON.encode!(poly)
        }
        |> Jason.encode!()

      conn
      |> get(project_path(conn, :index, bbox: "intersects:#{full_geojson}"))
      |> json_response(:ok)

      geom_only =
        Geo.JSON.encode!(poly)
        |> Jason.encode!()

      conn
      |> get(project_path(conn, :index, bbox: "intersects:#{geom_only}"))
      |> json_response(:ok)
    end

    test "a bad value will 400", %{conn: conn} do
      conn
      |> get(project_path(conn, :index, bbox: "intersects:western ave"))
      |> json_response(:bad_request)
    end
  end
end
