defmodule Aot.Testing.ObservationQueriesTest do
  use Aot.Testing.BaseCase

  alias Aot.ObservationActions

  test "include_node/1" do
    ObservationActions.list()
    |> Enum.map(& refute Ecto.assoc_loaded?(&1.node))

    ObservationActions.list(include_node: true)
    |> Enum.map(& assert Ecto.assoc_loaded?(&1.node))
  end

  test "include_sensor/1" do
    ObservationActions.list()
    |> Enum.map(& refute Ecto.assoc_loaded?(&1.sensor))

    ObservationActions.list(include_sensor: true)
    |> Enum.map(& assert Ecto.assoc_loaded?(&1.sensor))
  end

  test "include_networks/1" do
    ObservationActions.list()
    |> Enum.map(& refute Ecto.assoc_loaded?(&1.node))

    ObservationActions.list(include_networks: true)
    |> Enum.map(& assert Ecto.assoc_loaded?(&1.node.networks))
  end

  @tag add2ctx: :networks
  test "for_network/2", %{denver: denver} do
    obs = ObservationActions.list(for_network: denver)
    assert length(obs) == 12

  end

  @tag add2ctx: :nodes
  test "for_node/2", %{n000: node} do
    obs = ObservationActions.list(for_node: node)
    assert length(obs) == 12
  end

  @tag add2ctx: :sensors
  test "for_sensor/2", %{s1: s1, s13: s13} do
    obs = ObservationActions.list(for_sensor: s1)
    assert length(obs) == 0

    obs = ObservationActions.list(for_sensor: s13)
    assert length(obs) == 20
  end

  describe "timestamp_op/2" do
    @timestamp ~N[2018-10-01 00:01:00]

    test "eq" do
      obs = ObservationActions.list(timestamp_op: {:eq, @timestamp})
      assert length(obs) == 15
    end

    test "lt" do
      obs = ObservationActions.list(timestamp_op: {:lt, @timestamp})
      assert length(obs) == 30
    end

    test "le" do
      obs = ObservationActions.list(timestamp_op: {:le, @timestamp})
      assert length(obs) == 45
    end

    test "ge" do
      obs = ObservationActions.list(timestamp_op: {:ge, @timestamp})
      assert length(obs) == 30
    end

    test "gt" do
      obs = ObservationActions.list(timestamp_op: {:gt, @timestamp})
      assert length(obs) == 15
    end
  end

  describe "value_op/2" do
    @value 54.5

    test "eq" do
      obs = ObservationActions.list(value_op: {:eq, @value})
      assert length(obs) == 39
    end

    test "lt" do
      obs = ObservationActions.list(value_op: {:lt, @value})
      assert length(obs) == 0
    end

    test "le" do
      obs = ObservationActions.list(value_op: {:le, @value})
      assert length(obs) == 39
    end

    test "ge" do
      obs = ObservationActions.list(value_op: {:ge, @value})
      assert length(obs) == 60
    end

    test "gt" do
      obs = ObservationActions.list(value_op: {:gt, @value})
      assert length(obs) == 21
    end
  end

  test "located_within/2" do
    obs = ObservationActions.list(located_within: %Geo.Polygon{
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
    obs = ObservationActions.list(located_within: poly)
    assert length(obs) == 48
  end

  test "within_distance/2" do
    obs = ObservationActions.list(within_distance: {%Geo.Point{srid: 4326, coordinates: {1, 1}}, 1000})
    assert length(obs) == 0

    obs = ObservationActions.list(within_distance: {
      %Geo.Point{srid: 4326, coordinates: {-87.6022692567378, 41.8259500191867}},
      20000
    })
    assert length(obs) == 48
  end

  test "histogram/2" do
    ObservationActions.list(as_histogram: {0, 100, 10, :node_id})
    |> Enum.each(fn [_node_id, counts] ->
      assert length(counts) == 12
      Enum.each(counts, & &1 >= 0)
    end)
  end

  describe "value_agg/2" do
    test "first" do
      [first_obs] = ObservationActions.list(value_agg: {:first, nil})
      assert is_float(first_obs)
    end

    test "last" do
      [last_obs] = ObservationActions.list(value_agg: {:last, nil})
      assert is_float(last_obs)
    end

    test "count" do
      ObservationActions.list(value_agg: {:count, :node_id})
      |> Enum.each(fn [_node_id, count] -> assert count >= 0 end)
    end

    test "min" do
      ObservationActions.list(value_agg: {:min, :node_id})
      |> Enum.each(fn [_node_id, min] -> assert is_float(min) end)
    end

    test "max" do
      ObservationActions.list(value_agg: {:max, :node_id})
      |> Enum.each(fn [_node_id, max] -> assert is_float(max) end)
    end

    test "avg" do
      ObservationActions.list(value_agg: {:avg, :node_id})
      |> Enum.each(fn [_node_id, avg] -> assert is_float(avg) end)
    end

    test "sum" do
      ObservationActions.list(value_agg: {:sum, :node_id})
      |> Enum.each(fn [_node_id, sum] -> assert is_float(sum) end)
    end

    test "stddev" do
      ObservationActions.list(value_agg: {:stddev, :node_id})
      |> Enum.each(fn [_node_id, stddev] -> assert is_float(stddev) end)
    end

    test "variance" do
      ObservationActions.list(value_agg: {:variance, :node_id})
      |> Enum.each(fn [_node_id, variance] -> assert is_float(variance) end)
    end

    test "percentile (.5 ~ median)" do
      ObservationActions.list(value_agg: {:percentile, {0.5, :node_id}})
      |> Enum.each(fn [_node_id, median] -> assert is_float(median) end)
    end
  end

  describe "time_bucket/2" do
    test "count" do
      ObservationActions.list(as_time_buckets: {:count, "1 seconds"})
      |> Enum.each(fn [{_ymd, _hms}, count] -> assert count >= 0 end)
    end

    test "min" do
      ObservationActions.list(as_time_buckets: {:min, "1 seconds"})
      |> Enum.each(fn [{_ymd, _hms}, min] -> assert is_float(min) end)
    end

    test "max" do
      ObservationActions.list(as_time_buckets: {:max, "1 seconds"})
      |> Enum.each(fn [{_ymd, _hms}, max] -> assert is_float(max) end)
    end

    test "avg" do
      ObservationActions.list(as_time_buckets: {:avg, "1 seconds"})
      |> Enum.each(fn [{_ymd, _hms}, avg] -> assert is_float(avg) end)
    end

    test "sum" do
      ObservationActions.list(as_time_buckets: {:sum, "1 seconds"})
      |> Enum.each(fn [{_ymd, _hms}, sum] -> assert is_float(sum) end)
    end

    test "stddev" do
      ObservationActions.list(as_time_buckets: {:stddev, "1 seconds"})
      |> Enum.each(fn [{_ymd, _hms}, stddev] -> assert is_float(stddev) end)
    end

    test "variance" do
      ObservationActions.list(as_time_buckets: {:variance, "1 seconds"})
      |> Enum.each(fn [{_ymd, _hms}, variance] -> assert is_float(variance) end)
    end

    test "percentile (.5 ~ median)" do
      ObservationActions.list(as_time_buckets: {:percentile, {0.5, "1 seconds"}})
      |> Enum.each(fn [{_ymd, _hms}, min] -> assert is_float(min) end)
    end
  end

  test "handle_opts/2" do
    # i want the average humidity by node
    # from nodes within 20 km of my location
    # and i know a few of these nodes report
    # bad data, so i'm setting an upper bound

    pt = %Geo.Point{srid: 4326, coordinates: {-87.627678, 41.878377}}

    obs =
      ObservationActions.list(
        for_sensor: "metsense.hih4030.humidity",
        within_distance: {pt, 20000},
        value_agg: {:avg, :node_id},
        value_op: {:lt, 100},
      )

    assert length(obs) == 4
    Enum.each(obs, fn [_node_id, avg] -> assert avg < 100 end)
  end
end
