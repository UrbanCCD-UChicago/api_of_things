defmodule Aot.Testing.NetworkQueriesTest do
  use Aot.Testing.CompleteMetaCase

  alias Aot.NetworkActions

  test "with_nodes/1", %{net1: net1, node1: node1, node2: node2} do
    network = NetworkActions.get!(net1.id, with_nodes: true)
    node_ids = Enum.map(network.nodes, & &1.id)

    assert node_ids == [node1.id, node2.id]
  end

  test "with_sensors/1", %{net1: net1, sensor1: sensor1, sensor2: sensor2, sensor3: sensor3} do
    network = NetworkActions.get!(net1.id, with_sensors: true)
    sensor_ids = Enum.map(network.sensors, & &1.id)

    assert sensor_ids == [sensor1.id, sensor2.id, sensor3.id]
  end

  test "has_node/2", %{node1: node1, net1: net1, net2: net2} do
    network_ids =
      NetworkActions.list(has_node: node1)
      |> Enum.map(& &1.id)

    assert network_ids == [net1.id, net2.id]
  end

  test "has_nodes/2", %{node1: node1, node2: node2, net1: net1, net2: net2} do
    network_ids =
      NetworkActions.list(has_nodes: [node1, node2])
      |> Enum.map(& &1.id)

    assert network_ids == [net1.id, net2.id]
  end

  test "has_sensor/2", %{sensor3: sensor3, net1: net1, net2: net2} do
    network_ids =
      NetworkActions.list(has_sensor: sensor3)
      |> Enum.map(& &1.id)

    assert network_ids == [net1.id, net2.id]
  end

  test "has_sensors/2", %{sensor1: sensor1, sensor3: sensor3, net1: net1, net2: net2, net3: net3} do
    network_ids =
      NetworkActions.list(has_sensors: [sensor1, sensor3])
      |> Enum.map(& &1.id)

    assert network_ids == [net1.id, net2.id, net3.id]
  end

  test "bbox_contains/2", %{net3: net3} do
    networks = NetworkActions.list(bbox_contains: %Geo.Point{srid: 4326, coordinates: {0, 0}})
    assert length(networks) == 0

    network_ids =
      NetworkActions.list(bbox_contains: %Geo.Point{srid: 4326, coordinates: {-98.1234, 35.4321}})
      |> Enum.map(& &1.id)
    assert network_ids == [net3.id]
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
    assert network_ids == [net1.id, net2.id]
  end

  test "hull_contains/2", %{net3: net3} do
    networks = NetworkActions.list(hull_contains: %Geo.Point{srid: 4326, coordinates: {0, 0}})
    assert length(networks) == 0

    network_ids =
      NetworkActions.list(hull_contains: %Geo.Point{srid: 4326, coordinates: {-98.1234, 35.4321}})
      |> Enum.map(& &1.id)
    assert network_ids == [net3.id]
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
    assert network_ids == [net1.id, net2.id]
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
        with_nodes: true,
        with_sensors: true,
        has_sensors: [sensor1, sensor2],
        bbox_intersects: chi_poly
      )

    network_ids = Enum.map(networks, & &1.id)
    assert network_ids == [net1.id, net2.id]

    networks
    |> Enum.each(fn net ->
      assert Ecto.assoc_loaded?(net.nodes)
      assert Ecto.assoc_loaded?(net.sensors)
    end)
  end
end
