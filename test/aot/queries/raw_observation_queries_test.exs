defmodule Aot.Testing.RawObservationQueriesTest do
  use Aot.Testing.BaseCase

  alias Aot.RawObservationActions

  test "include_node/1" do
    RawObservationActions.list()
    |> Enum.map(& refute Ecto.assoc_loaded?(&1.node))

    RawObservationActions.list(include_node: true)
    |> Enum.map(& assert Ecto.assoc_loaded?(&1.node))
  end

  test "include_sensor/1" do
    RawObservationActions.list()
    |> Enum.map(& refute Ecto.assoc_loaded?(&1.sensor))

    RawObservationActions.list(include_sensor: true)
    |> Enum.map(& assert Ecto.assoc_loaded?(&1.sensor))
  end

  test "include_networks/1" do
    RawObservationActions.list()
    |> Enum.map(& refute Ecto.assoc_loaded?(&1.node))

    RawObservationActions.list(include_networks: true)
    |> Enum.map(& assert Ecto.assoc_loaded?(&1.node.networks))
  end

  @tag add2ctx: :networks
  test "for_network/2", %{denver: denver} do
    obs = RawObservationActions.list(for_network: denver)
    assert length(obs) == 12

  end

  @tag add2ctx: :nodes
  test "for_node/2", %{n000: node} do
    obs = RawObservationActions.list(for_node: node)
    assert length(obs) == 12
  end

  @tag add2ctx: :sensors
  test "for_sensor/2", %{s1: s1, s13: s13} do
    obs = RawObservationActions.list(for_sensor: s1)
    assert length(obs) == 12

    obs = RawObservationActions.list(for_sensor: s13)
    assert length(obs) == 20
  end

  describe "timestamp_op/2" do
    @timestamp ~N[2018-10-01 00:01:00]

    test "eq" do
      obs = RawObservationActions.list(timestamp_op: {:eq, @timestamp})
      assert length(obs) == 45
    end

    test "lt" do
      obs = RawObservationActions.list(timestamp_op: {:lt, @timestamp})
      assert length(obs) == 90
    end

    test "le" do
      obs = RawObservationActions.list(timestamp_op: {:le, @timestamp})
      assert length(obs) == 135
    end

    test "ge" do
      obs = RawObservationActions.list(timestamp_op: {:ge, @timestamp})
      assert length(obs) == 90
    end

    test "gt" do
      obs = RawObservationActions.list(timestamp_op: {:gt, @timestamp})
      assert length(obs) == 45
    end
  end

  test "located_within/2" do
    obs = RawObservationActions.list(located_within: %Geo.Polygon{
      srid: 4326,
      coordinates: [[
        {1, 1},
        {1, 2},
        {2, 2},
        {2, 1},
        {1, 1}
      ]]
    })
    assert length(obs) == 0

    poly = %Geo.Polygon{
      srid: 4326,
      coordinates: [[
        {-89, 40},
        {-89, 45},
        {-85, 45},
        {-85, 40},
        {-89, 40}
      ]]
    }
    obs = RawObservationActions.list(located_within: poly)
    assert length(obs) == 168
  end

  test "within_distance/2" do
    obs = RawObservationActions.list(within_distance: {%Geo.Point{srid: 4326, coordinates: {1, 1}}, 1000})
    assert length(obs) == 0

    obs = RawObservationActions.list(within_distance: {
      %Geo.Point{srid: 4326, coordinates: {-87.6022692567378, 41.8259500191867}},
      20000
    })
    assert length(obs) == 168
  end
end
