defmodule Aot.Testing.ObservationQueriesTest do
  use ExUnit.Case

  alias Aot.{
    M2MActions,
    NetworkActions,
    NodeActions,
    ObservationActions,
    SensorActions
  }

  # NOTE: this is run once at the start of the tests. it's a heavy procedure and
  # doesn't need to be rerun for each test case. also note that it pretty thoroughly
  # tests ObservationActions.create/1 .
  setup_all do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Aot.Repo)
    :ok = Ecto.Adapters.SQL.Sandbox.mode(Aot.Repo, {:shared, self()})

    {:ok, network} =
      NetworkActions.create(
        name: "Chicago Public",
        archive_url: "https://example.com/archive",
        recent_url: "https://example.com/recent",
        first_observation: ~N[2018-01-01 00:00:00],
        latest_observation: NaiveDateTime.utc_now()
      )

    "test/fixtures/chicago-public.csv"
    |> File.stream!()
    |> CSV.decode!(headers: true)
    |> Enum.each(fn row ->
      # create node
      ok_node? =
        NodeActions.create(
          id: row["node_id"],
          vsn: row["node_id"],
          longitude: -87.1234,
          latitude: 41.4321,
          commissioned_on: ~N[2018-04-21 15:00:00]
        )
      node =
        case ok_node? do
          {:ok, node} ->
            {:ok, _} = M2MActions.create_network_node(network: network, node: node)
            node

          {:error, _} ->
            NodeActions.get!(row["node_id"])
        end

      # create sensor
      ok_sensor? =
        SensorActions.create(
          ontology: "whatever",
          subsystem: row["subsystem"],
          sensor: row["sensor"],
          parameter: row["parameter"]
        )
      sensor =
        case ok_sensor? do
          {:ok, sensor} ->
            {:ok, _} = M2MActions.create_network_sensor(network: network, sensor: sensor)
            sensor

          {:error, _} ->
            path = "#{row["subsystem"]}.#{row["sensor"]}.#{row["parameter"]}"
            SensorActions.get!(path)
        end

      # create node_sensor
      {:ok, _} = M2MActions.create_node_sensor(node: node, sensor: sensor)

      # insert observations
      timestamp = Timex.parse!(row["timestamp"], "%Y/%m/%d %H:%M:%S", :strftime)

      case parse_value(row, "value_hrf") do
        nil -> :ok
        parsed -> {:ok, _} = ObservationActions.create(node: node, sensor: sensor, timestamp: timestamp, value: parsed)
      end

      case parse_value(row, "value_raw") do
        nil -> :ok
        parsed -> {:ok, _} = ObservationActions.create(node: node, sensor: sensor, timestamp: timestamp, value: parsed, raw?: true)
      end
    end)

    node = NodeActions.get!("001e0610ee41")

    sensor = SensorActions.get!("lightsense.apds_9006_020.intensity")

    {:ok, network: network, node: node, sensor: sensor}
  end

  defp parse_value(row, key) do
    raw = row[key]
    cond do
      is_number(raw) ->
        raw

      is_nil(raw) ->
        nil

      true ->
        try do
          String.to_float(raw)
        rescue
          ArgumentError ->
            try do
              String.to_integer(raw)
            rescue
              ArgumentError ->
                nil
            end
        end
    end
  end

  @num_obs 906
  @hrf 744
  @raw 162

  @node_obs 18

  @sensor_obs 28

  @timestamp ~N[2018-09-28 16:35:48]
  @ts_eq 66
  @ts_lt 186
  @ts_le 252
  @ts_ge 720
  @ts_gt 654

  @value 54.51
  @v_eq 1
  @v_lt 534
  @v_le 535
  @v_ge 372
  @v_gt 371

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

  test "assert_hrf/1" do
    obs = ObservationActions.list(assert_hrf: true)
    assert length(obs) == @hrf
  end

  test "assert_raw/1" do
    obs = ObservationActions.list(assert_raw: true)
    assert length(obs) == @raw
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

    obs = ObservationActions.list(for_network: net)
    assert length(obs) == 0

    obs = ObservationActions.list(for_network: network)
    assert length(obs) == @num_obs

  end

  test "for_node/2", %{node: node} do
    obs = ObservationActions.list(for_node: node)
    assert length(obs) == @node_obs
  end

  test "for_sensor/2", %{sensor: sensor} do
    obs = ObservationActions.list(for_sensor: sensor)
    assert length(obs) == @sensor_obs
  end

  describe "timestamp_op/2" do
    test "eq" do
      obs = ObservationActions.list(timestamp_op: {:eq, @timestamp})
      assert length(obs) == @ts_eq
    end

    test "lt" do
      obs = ObservationActions.list(timestamp_op: {:lt, @timestamp})
      assert length(obs) == @ts_lt
    end

    test "le" do
      obs = ObservationActions.list(timestamp_op: {:le, @timestamp})
      assert length(obs) == @ts_le
    end

    test "ge" do
      obs = ObservationActions.list(timestamp_op: {:ge, @timestamp})
      assert length(obs) == @ts_ge
    end

    test "gt" do
      obs = ObservationActions.list(timestamp_op: {:gt, @timestamp})
      assert length(obs) == @ts_gt
    end
  end

  describe "value_op/2" do
    test "eq" do
      obs = ObservationActions.list(value_op: {:eq, @value})
      assert length(obs) == @v_eq
    end

    test "lt" do
      obs = ObservationActions.list(value_op: {:lt, @value})
      assert length(obs) == @v_lt
    end

    test "le" do
      obs = ObservationActions.list(value_op: {:le, @value})
      assert length(obs) == @v_le
    end

    test "ge" do
      obs = ObservationActions.list(value_op: {:ge, @value})
      assert length(obs) == @v_ge
    end

    test "gt" do
      obs = ObservationActions.list(value_op: {:gt, @value})
      assert length(obs) == @v_gt
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

    obs = ObservationActions.list(located_within: @polygon)
    assert length(obs) == @num_obs
  end

  test "within_distance/2" do
    obs = ObservationActions.list(within_distance: {%Geo.Point{srid: 4326, coordinates: {1, 1}}, 1000})
    assert length(obs) == 0

    obs = ObservationActions.list(within_distance: @point_and_distance)
    assert length(obs) == @num_obs
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
    # i want the average temperature by node
    # from nodes within 2 km of my location
    # and i know a few of these nodes report
    # bad data, so i'm setting an upper bound
    ObservationActions.list(
      for_sensor: "metsense.bmp180.temperature",
      within_distance: @point_and_distance,
      value_agg: {:avg, :node_id},
      value_op: {:lt, 100}
    )
    |> Enum.each(fn [_node_id, avg] -> assert avg < 100 end)
  end
end
