defmodule Aot.Testing.NodeQueriesTest do
  use Aot.Testing.CompleteMetaCase

  alias Aot.NodeActions

  test "with_networks/1" do
    NodeActions.list()
    |> Enum.each(& refute Ecto.assoc_loaded?(&1.networks))

    NodeActions.list(with_networks: true)
    |> Enum.each(& assert Ecto.assoc_loaded?(&1.networks))
  end

  test "with_sensors/1" do
    NodeActions.list()
    |> Enum.each(& refute Ecto.assoc_loaded?(&1.sensors))

    NodeActions.list(with_sensors: true)
    |> Enum.each(& assert Ecto.assoc_loaded?(&1.sensors))
  end

  test "assert_alive/1" do
    nodes = NodeActions.list(assert_alive: true)
    assert length(nodes) == 3
  end

  test "assert_dead/1" do
    nodes = NodeActions.list(assert_dead: true)
    assert length(nodes) == 0
  end

  test "within_network/2", %{net1: net1, node1: node1, node2: node2} do
    node_ids =
      NodeActions.list(within_network: net1)
      |> Enum.map(& &1.id)

    assert length(node_ids) == 2

    [node1.id, node2.id]
    |> Enum.each(& assert Enum.member?(node_ids, &1))
  end

  test "witin_networks/2", %{net1: net1, net3: net3, node1: node1, node2: node2, node3: node3} do
    node_ids =
      NodeActions.list(within_networks: [net1, net3])
      |> Enum.map(& &1.id)

    assert length(node_ids) == 3

    [node1.id, node2.id, node3.id]
    |> Enum.each(& assert Enum.member?(node_ids, &1))
  end

  test "has_sensor/2", %{sensor3: sensor3, node1: node1, node2: node2} do
    node_ids =
      NodeActions.list(has_sensor: sensor3)
      |> Enum.map(& &1.id)

    assert length(node_ids) == 2

    [node1.id, node2.id]
    |> Enum.each(& assert Enum.member?(node_ids, &1))
  end

  test "has_sensors/2", %{sensor1: sensor1, sensor2: sensor2, node1: node1, node2: node2, node3: node3} do
    node_ids =
      NodeActions.list(has_sensors: [sensor1, sensor2])
      |> Enum.map(& &1.id)

    assert length(node_ids) == 3

    [node1.id, node2.id, node3.id]
    |> Enum.each(& assert Enum.member?(node_ids, &1))
  end

  test "located_witin/2", %{node1: node1, node2: node2} do
    nodes = NodeActions.list(located_within: %Geo.Polygon{
      srid: 4326,
      coordinates: [[
        {1, 2},
        {1, 1},
        {2, 1},
        {2, 2},
        {1, 2}
      ]]
    })
    assert length(nodes) == 0

    node_ids =
      NodeActions.list(located_within: %Geo.Polygon{
        srid: 4326,
        coordinates: [[
          {-89, 40},
          {-89, 45},
          {-85, 45},
          {-85, 40},
          {-89, 40}
        ]]
      })
      |> Enum.map(& &1.id)

    assert length(node_ids) == 2

    [node1.id, node2.id]
    |> Enum.each(& assert Enum.member?(node_ids, &1))
  end

  test "within_distance", %{node3: node3} do
    nodes = NodeActions.list(within_distance: {%Geo.Point{srid: 4326, coordinates: {1, 2}}, 2000})
    assert length(nodes) == 0

    node_ids =
      NodeActions.list(within_distance: {%Geo.Point{srid: 4326, coordinates: {-98.12, 35.43}}, 2000})
      |> Enum.map(& &1.id)

    assert length(node_ids) == 1

    [node3.id]
    |> Enum.each(& assert Enum.member?(node_ids, &1))
  end

  describe "commissioned_on_op/2" do
    test "eq", %{node1: node1} do
      node_ids =
        NodeActions.list(commissioned_on_op: {:eq, ~N[2018-04-21 15:00:00]})
        |> Enum.map(& &1.id)

      assert length(node_ids) == 1

      [node1.id]
      |> Enum.each(& assert Enum.member?(node_ids, &1))
    end

    test "lt", %{node2: node2, node3: node3} do
      node_ids =
        NodeActions.list(commissioned_on_op: {:lt, ~N[2018-04-21 15:00:00]})
        |> Enum.map( & &1.id)

      assert length(node_ids) == 2

      [node3.id, node2.id]
      |> Enum.each(& assert Enum.member?(node_ids, &1))
    end

    test "le", %{node1: node1, node2: node2, node3: node3} do
      node_ids =
        NodeActions.list(commissioned_on_op: {:le, ~N[2018-04-21 15:00:00]})
        |> Enum.map( & &1.id)

      assert length(node_ids) == 3

      [node1.id, node2.id, node3.id]
      |> Enum.each(& assert Enum.member?(node_ids, &1))
    end

    test "ge", %{node1: node1} do
      node_ids =
        NodeActions.list(commissioned_on_op: {:ge, ~N[2018-04-21 15:00:00]})
        |> Enum.map(& &1.id)

      assert length(node_ids) == 1

      [node1.id]
      |> Enum.each(& assert Enum.member?(node_ids, &1))
    end

    test "gt" do
      node_ids =
        NodeActions.list(commissioned_on_op: {:gt, ~N[2018-04-21 15:00:00]})
        |> Enum.map(& &1.id)

      assert node_ids == []
    end
  end

  test "handle_opts/2", %{node1: node1, node2: node2, net1: net1, net2: net2, sensor1: sensor1, sensor2: sensor2, sensor3: sensor3} do
    # make node2 dead
    {:ok, node2} = NodeActions.update(node2, decommissioned_on: NaiveDateTime.utc_now())

    nodes =
      NodeActions.list(
        with_networks: true,
        with_sensors: true,
        assert_alive: true,
        has_sensor: sensor1,
        within_distance: {%Geo.Point{srid: 4326, coordinates: {-87.12, 41.43}}, 2000}
      )

    assert length(nodes) == 1
    node = List.first(nodes)

    assert node.id == node1.id
    assert Enum.map(node.networks, & &1.id) == [net1.id, net2.id]
    assert Enum.map(node.sensors, & &1.id) == [sensor1.id, sensor2.id, sensor3.id]

    # undo kill
    {:ok, _} = NodeActions.update(node2, decommissioned_on: nil)
  end
end
