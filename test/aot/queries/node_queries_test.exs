defmodule Aot.Testing.NodeQueriesTest do
  use Aot.Testing.BaseCase

  alias Aot.NodeActions

  test "include_networks/1" do
    NodeActions.list()
    |> Enum.each(& refute Ecto.assoc_loaded?(&1.networks))

    NodeActions.list(include_networks: true)
    |> Enum.each(& assert Ecto.assoc_loaded?(&1.networks))
  end

  test "include_sensors/1" do
    NodeActions.list()
    |> Enum.each(& refute Ecto.assoc_loaded?(&1.sensors))

    NodeActions.list(include_sensors: true)
    |> Enum.each(& assert Ecto.assoc_loaded?(&1.sensors))
  end

  test "assert_alive/1" do
    nodes = NodeActions.list(assert_alive: true)
    assert length(nodes) == 5
  end

  test "assert_dead/1" do
    nodes = NodeActions.list(assert_dead: true)
    assert length(nodes) == 1
  end

  @tag add2ctx: [:networks, :nodes]
  test "within_networks/2", %{denver: denver, chicago_complete: chic} do
    nodes = NodeActions.list(within_network: denver)
    assert length(nodes) == 1

    nodes = NodeActions.list(within_networks: [denver, chic])
    assert length(nodes) == 6
  end

  @tag add2ctx: [:sensors, :nodes]
  test "has_sensors/2", %{s12: s12, s13: s13} do
    nodes = NodeActions.list(has_sensor: s12)
    assert length(nodes) == 5

    nodes = NodeActions.list(has_sensors: [s12, s13])
    assert length(nodes) == 5
  end

  test "located_witin/2" do
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

    nodes =
      NodeActions.list(located_within:
        %Geo.Polygon{
          srid: 4326,
          coordinates: [[
            {-89, 40},
            {-89, 45},
            {-85, 45},
            {-85, 40},
            {-89, 40}
          ]]
        })

    assert length(nodes) == 5
  end

  test "within_distance" do
    nodes = NodeActions.list(within_distance: {%Geo.Point{srid: 4326, coordinates: {1, 2}}, 2000})
    assert length(nodes) == 0

    nodes =
      NodeActions.list(within_distance: {
        %Geo.Point{srid: 4326, coordinates: {-87.6022692567378, 41.8259500191867}},
        20000
      })

    assert length(nodes) == 5
  end

  describe "commissioned_on_op/2" do
    test "eq" do
      nodes = NodeActions.list(commissioned_on_op: {:eq, ~N[2018-04-21 15:00:00]})
      assert nodes == []
    end

    test "lt" do
      nodes = NodeActions.list(commissioned_on_op: {:lt, ~N[2018-04-21 15:00:00]})
      assert length(nodes) == 6
    end

    test "le" do
      nodes = NodeActions.list(commissioned_on_op: {:le, ~N[2017-12-01 00:00:00]})
      assert length(nodes) == 4
    end

    test "ge" do
      nodes = NodeActions.list(commissioned_on_op: {:ge, ~N[2017-12-01 00:00:00]})
      assert length(nodes) == 3
    end

    test "gt" do
      nodes = NodeActions.list(commissioned_on_op: {:gt, ~N[2018-04-21 15:00:00]})
      assert nodes == []
    end
  end

  @tag add2ctx: [:sensors, :nodes]
  test "handle_opts/2", %{s1: s1, n004: n004, n006: n006, n00D: n00D} do
    nodes =
      NodeActions.list(
        include_networks: true,
        include_sensors: true,
        assert_alive: true,
        has_sensor: s1,
        within_distance: {%Geo.Point{srid: 4326, coordinates: {-87.6022692567378, 41.8259500191867}}, 20000}
      )

    assert length(nodes) == 3

    node_ids = Enum.map(nodes, & &1.id)
    [n004.id, n006.id, n00D.id]
    |> Enum.each(& assert Enum.member?(node_ids, &1))

    nodes
    |> Enum.each(fn node ->
      assert Ecto.assoc_loaded?(node.networks)
      assert Ecto.assoc_loaded?(node.sensors)
      assert Enum.member?(Enum.map(node.sensors, & &1.id), s1.id)
    end)
  end
end
