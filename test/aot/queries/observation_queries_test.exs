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

  test "with_node/1" do
    ObservationActions.list()
    |> Enum.map(& refute Ecto.assoc_loaded?(&1.node))

    ObservationActions.list(with_node: true)
    |> Enum.map(& assert Ecto.assoc_loaded?(&1.node))
  end

  test "with_sensor/1" do
    ObservationActions.list()
    |> Enum.map(& refute Ecto.assoc_loaded?(&1.sensor))

    ObservationActions.list(with_sensor: true)
    |> Enum.map(& assert Ecto.assoc_loaded?(&1.sensor))
  end

  test "with_networks/1" do
    ObservationActions.list()
    |> Enum.map(& refute Ecto.assoc_loaded?(&1.node))

    ObservationActions.list(with_networks: true)
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

  # test "histogram/2"

  # describe "value_agg/2" do
  #   test "first"

  #   test "last"

  #   test "count"

  #   test "min"

  #   test "max"

  #   test "avg"

  #   test "sum"

  #   test "stddev"

  #   test "variance"

  #   test "percentile (.5 ~ median)"
  # end

  # describe "time_bucket/2" do
  #   test "first"

  #   test "last"

  #   test "count"

  #   test "min"

  #   test "max"

  #   test "avg"

  #   test "sum"

  #   test "stddev"

  #   test "variance"

  #   test "percentile (.5 ~ median)"
  # end
end
