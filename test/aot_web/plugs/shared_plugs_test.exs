defmodule AotWeb.SharedPlugsTest do
  use AotWeb.ConnCase, async: true

  @tag add2ctx: :projects
  test "for project", %{conn: conn, chicago: project} do
    %{"data" => data} =
      conn
      |> get(Routes.observation_path(conn, :index, project: project.slug))
      |> json_response(:ok)

    assert is_list(data)
    assert length(data) == 200
  end

  # @tag add2ctx: :nodes
  # test "for node", %{conn: conn, n004: node} do
  #   %{"data" => data} =
  #     conn
  #     |> get(Routes.observation_path(conn, :index, node: node.vsn))
  #     |> json_response(:ok)

  #   assert is_list(data)
  #   assert length(data) > 0
  # end

  @tag add2ctx: :sensors
  test "for sensor", %{conn: conn, lightsense_apds_9006_020_intensity: sensor} do
    %{"data" => data} =
      conn
      |> get(Routes.observation_path(conn, :index, sensor: sensor.path))
      |> json_response(:ok)

    assert is_list(data)
    assert length(data) > 0
  end

  @tag add2ctx: :nodes
  test "unknown format should return 422", %{conn: conn, n004: node} do
    conn
    |> get(Routes.node_path(conn, :show, node, format: "yaml"))
    |> json_response(:unprocessable_entity)
  end

  test "located within", %{conn: conn} do
    geom =
      %Geo.Polygon{srid: 4326, coordinates: [[
        {-87, 42},
        {-87, 41},
        {-88, 41},
        {-88, 42},
        {-87, 42}
      ]]}
      |> Geo.JSON.encode!()
      |> Jason.encode!()

    %{"data" => data} =
      conn
      |> get(Routes.observation_path(conn, :index, located_within: geom))
      |> json_response(:ok)

    assert is_list(data)
    assert length(data) > 0
  end

  test "located within no results should return empty list", %{conn: conn} do
    geom =
      %Geo.Polygon{srid: 4326, coordinates: [[
        {-1, 2},
        {-1, 1},
        {0, 1},
        {0, 2},
        {-1, 2}
      ]]}
      |> Geo.JSON.encode!()
      |> Jason.encode!()

    %{"data" => data} =
      conn
      |> get(Routes.observation_path(conn, :index, located_within: geom))
      |> json_response(:ok)

    assert is_list(data)
    assert length(data) == 0
  end

  # test "located dwithin", %{conn: conn} do
  #   geom =
  #     %Geo.Point{srid: 4326, coordinates: {-87.627678, 41.878377}}
  #     |> Geo.JSON.encode!()
  #     |> Jason.encode!()
  #   distance = 500
  #   query = "#{distance}:#{geom}"

  #   %{"data" => data} =
  #     conn
  #     |> get(Routes.observation_path(conn, :index, located_dwithin: query))
  #     |> json_response(:ok)

  #   assert is_list(data)
  #   assert length(data) > 0
  # end

  test "located dwithin no results should return empty list", %{conn: conn} do
    geom =
      %Geo.Point{srid: 4326, coordinates: {-1, 1}}
      |> Geo.JSON.encode!()
      |> Jason.encode!()
    distance = 500
    query = "#{distance}:#{geom}"

    %{"data" => data} =
      conn
      |> get(Routes.observation_path(conn, :index, located_dwithin: query))
      |> json_response(:ok)

    assert is_list(data)
    assert length(data) == 0
  end
end
