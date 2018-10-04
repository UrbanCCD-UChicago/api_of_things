defmodule Aot.Testing.RawObservationQueriesTest do
  use Aot.Testing.RawObservationsCase

  alias Aot.{
    NetworkActions,
    RawObservationActions
  }

  @num_obs 806

  @node_obs 11

  @sensor_obs 28

  @timestamp ~N[2018-09-28 16:35:48]
  @ts_eq 61
  @ts_lt 161
  @ts_le 222
  @ts_ge 645
  @ts_gt 584

  @polygon %Geo.Polygon{
    srid: 4326,
    coordinates: [[
      {-89, 40},
      {-89, 45},
      {-85, 45},
      {-85, 40},
      {-89, 40}
    ]]
  }

  @point_and_distance {%Geo.Point{srid: 4326, coordinates: {-87.12, 41.43}}, 2000}

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

  test "for_network/2", %{network: network} do
    {:ok, net} =
      NetworkActions.create(
        name: "Chicago Complete",
        archive_url: "https://example.com/archive1",
        recent_url: "https://example.com/recent1",
        first_observation: ~N[2018-01-01 00:00:00],
        latest_observation: NaiveDateTime.utc_now()
      )

    obs = RawObservationActions.list(for_network: net)
    assert length(obs) == 0

    obs = RawObservationActions.list(for_network: network)
    assert length(obs) == @num_obs

  end

  test "for_node/2", %{node: node} do
    obs = RawObservationActions.list(for_node: node)
    assert length(obs) == @node_obs
  end

  test "for_sensor/2", %{sensor: sensor} do
    obs = RawObservationActions.list(for_sensor: sensor)
    assert length(obs) == @sensor_obs
  end

  describe "timestamp_op/2" do
    test "eq" do
      obs = RawObservationActions.list(timestamp_op: {:eq, @timestamp})
      assert length(obs) == @ts_eq
    end

    test "lt" do
      obs = RawObservationActions.list(timestamp_op: {:lt, @timestamp})
      assert length(obs) == @ts_lt
    end

    test "le" do
      obs = RawObservationActions.list(timestamp_op: {:le, @timestamp})
      assert length(obs) == @ts_le
    end

    test "ge" do
      obs = RawObservationActions.list(timestamp_op: {:ge, @timestamp})
      assert length(obs) == @ts_ge
    end

    test "gt" do
      obs = RawObservationActions.list(timestamp_op: {:gt, @timestamp})
      assert length(obs) == @ts_gt
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

    obs = RawObservationActions.list(located_within: @polygon)
    assert length(obs) == @num_obs
  end

  test "within_distance/2" do
    obs = RawObservationActions.list(within_distance: {%Geo.Point{srid: 4326, coordinates: {1, 1}}, 1000})
    assert length(obs) == 0

    obs = RawObservationActions.list(within_distance: @point_and_distance)
    assert length(obs) == @num_obs
  end
end
