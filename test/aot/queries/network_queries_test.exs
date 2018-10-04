defmodule Aot.Testing.NetworkQueriesTest do
  use Aot.Testing.CompleteMetaCase

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

  test "has_node/2", %{node1: node1, net1: net1, net2: net2} do
    network_ids =
      NetworkActions.list(has_node: node1)
      |> Enum.map(& &1.id)

    assert length(network_ids) == 2

    [net1.id, net2.id]
    |> Enum.each(& assert Enum.member?(network_ids, &1))
  end

  test "has_nodes/2", %{node1: node1, node2: node2, net1: net1, net2: net2} do
    network_ids =
      NetworkActions.list(has_nodes: [node1, node2])
      |> Enum.map(& &1.id)

    assert length(network_ids) == 2

    [net1.id, net2.id]
    |> Enum.each(& assert Enum.member?(network_ids, &1))
  end

  test "has_sensor/2", %{sensor3: sensor3, net1: net1, net2: net2} do
    network_ids =
      NetworkActions.list(has_sensor: sensor3)
      |> Enum.map(& &1.id)

    assert length(network_ids) == 2

    [net1.id, net2.id]
    |> Enum.each(& assert Enum.member?(network_ids, &1))
  end

  test "has_sensors/2", %{sensor1: sensor1, sensor3: sensor3, net1: net1, net2: net2, net3: net3} do
    network_ids =
      NetworkActions.list(has_sensors: [sensor1, sensor3])
      |> Enum.map(& &1.id)

    assert length(network_ids) == 3

    [net1.id, net2.id, net3.id]
    |> Enum.each(& assert Enum.member?(network_ids, &1))
  end

  test "bbox_contains/2", %{net3: net3} do
    networks = NetworkActions.list(bbox_contains: %Geo.Point{srid: 4326, coordinates: {0, 0}})
    assert length(networks) == 0

    network_ids =
      NetworkActions.list(bbox_contains: %Geo.Point{srid: 4326, coordinates: {-98.1234, 35.4321}})
      |> Enum.map(& &1.id)

    assert length(network_ids) == 1

    [net3.id]
    |> Enum.each(& assert Enum.member?(network_ids, &1))
  end

  test "bbox_intersects/2", %{net1: net1, net2: net2} do
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
    network_ids =
      NetworkActions.list(bbox_intersects: chi_poly)
      |> Enum.map(& &1.id)

    assert length(network_ids) == 2

    [net1.id, net2.id]
    |> Enum.each(& assert Enum.member?(network_ids, &1))
  end

  test "hull_contains/2", %{net3: net3} do
    networks = NetworkActions.list(hull_contains: %Geo.Point{srid: 4326, coordinates: {0, 0}})
    assert length(networks) == 0

    network_ids =
      NetworkActions.list(hull_contains: %Geo.Point{srid: 4326, coordinates: {-98.1234, 35.4321}})
      |> Enum.map(& &1.id)

    assert length(network_ids) == 1

    [net3.id]
    |> Enum.each(& assert Enum.member?(network_ids, &1))
  end

  test "hull_intersects/2", %{net1: net1, net2: net2} do
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
    network_ids =
      NetworkActions.list(hull_intersects: chi_poly)
      |> Enum.map(& &1.id)

    assert length(network_ids) == 2

    [net1.id, net2.id]
    |> Enum.each(& assert Enum.member?(network_ids, &1))
  end

  test "handle_opts/2", %{sensor1: sensor1, sensor2: sensor2, net1: net1, net2: net2} do
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
        has_sensors: [sensor1, sensor2],
        bbox_intersects: chi_poly
      )

    network_ids = Enum.map(networks, & &1.id)

    assert length(network_ids) == 2

    [net1.id, net2.id]
    |> Enum.each(& assert Enum.member?(network_ids, &1))

    networks
    |> Enum.each(fn net ->
      assert Ecto.assoc_loaded?(net.nodes)
      assert Ecto.assoc_loaded?(net.sensors)
    end)
  end
end
