defmodule Aot.Testing.NetworkQueriesTest do
  use Aot.Testing.BaseCase

  alias Aot.NetworkActions

  test "include_nodes/1" do
    NetworkActions.list()
    |> Enum.each(& refute Ecto.assoc_loaded?(&1.nodes))

    NetworkActions.list(include_nodes: true)
    |> Enum.each(& assert Ecto.assoc_loaded?(&1.nodes))
  end

  test "include_sensors/1" do
    NetworkActions.list()
    |> Enum.each(& refute Ecto.assoc_loaded?(&1.sensors))

    NetworkActions.list(include_sensors: true)
    |> Enum.each(& assert Ecto.assoc_loaded?(&1.sensors))
  end

  @tag add2ctx: :nodes
  test "has_nodes/2", %{n000: n000, n004: n004, n006: n006} do
    networks = NetworkActions.list(has_node: n000)
    assert length(networks) == 1

    networks = NetworkActions.list(has_nodes: [n004, n006])
    assert length(networks) == 2
  end

  @tag add2ctx: :sensors
  test "has_sensors/2", %{s1: s1, s2: s2, s13: s13} do
    networks = NetworkActions.list(has_sensor: s13)
    assert length(networks) == 3

    networks = NetworkActions.list(has_sensors: [s1, s2])
    assert length(networks) == 1
  end

  test "bbox_contains/2" do
    nope_point = %Geo.Point{srid: 4326, coordinates: {0, 0}}
    networks = NetworkActions.list(bbox_contains: nope_point)
    assert length(networks) == 0

    point = %Geo.Point{srid: 4326, coordinates: {-87.6, 41.8}}
    networks = NetworkActions.list(bbox_contains: point)
    assert length(networks) == 2
  end

  @tag add2ctx: :networks
  test "bbox_intersects/2" do
    nope_poly = %Geo.Polygon{
      srid: 4326,
      coordinates: [[
        {1, 1},
        {1, 2},
        {2, 2},
        {2, 1},
        {1, 1}
      ]]
    }
    networks = NetworkActions.list(bbox_intersects: nope_poly)
    assert length(networks) == 0

    chi_poly = %Geo.Polygon{
      srid: 4326,
      coordinates: [[
        {-88, 40},
        {-88, 43},
        {-86, 43},
        {-86, 40},
        {-88, 40}
      ]]
    }
    networks = NetworkActions.list(bbox_intersects: chi_poly)
    assert length(networks) == 2
  end

  test "hull_contains/2" do
    nope_point = %Geo.Point{srid: 4326, coordinates: {0, 0}}
    networks = NetworkActions.list(hull_contains: nope_point)
    assert length(networks) == 0

    point = %Geo.Point{srid: 4326, coordinates: {-87.6022692567378, 41.8259500191867}}
    networks = NetworkActions.list(hull_contains: point)
    assert length(networks) == 2
  end

  test "hull_intersects/2" do
    nope_poly = %Geo.Polygon{
      srid: 4326,
      coordinates: [[
        {1, 1},
        {1, 2},
        {2, 2},
        {2, 1},
        {1, 1}
      ]]
    }
    networks = NetworkActions.list(hull_intersects: nope_poly)
    assert length(networks) == 0

    chi_poly = %Geo.Polygon{
      srid: 4326,
      coordinates: [[
        {-88, 40},
        {-88, 43},
        {-86, 43},
        {-86, 40},
        {-88, 40}
      ]]
    }
    networks = NetworkActions.list(hull_intersects: chi_poly)
    assert length(networks) == 2
  end

  @tag add2ctx: [:sensors, :networks]
  test "handle_opts/2", %{s1: s1, s2: s2, chicago_complete: chic} do
    chi_poly = %Geo.Polygon{
      srid: 4326,
      coordinates: [[
        {-88, 40},
        {-88, 43},
        {-86, 43},
        {-86, 40},
        {-88, 40}
      ]]
    }

    networks =
      NetworkActions.list(
        include_nodes: true,
        include_sensors: true,
        has_sensors: [s1, s2],
        bbox_intersects: chi_poly
      )

    network_ids = Enum.map(networks, & &1.id)
    assert network_ids == [chic.id]

    networks
    |> Enum.each(fn net ->
      assert Ecto.assoc_loaded?(net.nodes)
      assert Ecto.assoc_loaded?(net.sensors)
    end)
  end
end
