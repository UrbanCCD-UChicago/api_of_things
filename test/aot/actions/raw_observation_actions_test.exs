defmodule Aot.Testing.RawObservationActionsTest do
  use ExUnit.Case

  alias Aot.{
    M2MActions,
    NetworkActions,
    NodeActions,
    RawObservationActions,
    SensorActions
  }

  # NOTE: this is run once at the start of the tests. it's a heavy procedure and
  # doesn't need to be rerun for each test case. also note that it pretty thoroughly
  # tests RawObservationActions.create/1 .
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

      case parse_value(row, "value_raw") do
        nil ->
          :ok

        parsed ->
          hrf = parse_value(row, "value_hrf")
          {:ok, _} = RawObservationActions.create(node: node, sensor: sensor, timestamp: timestamp, hrf: hrf, raw: parsed)
      end
    end)

    node = NodeActions.get!("001e0610ee41")

    sensor = SensorActions.get!("lightsense.apds_9006_020.intensity")

    {:ok, network: network, node: node, sensor: sensor}
  end

  defp parse_value(row, key) do
    value = row[key]
    case Regex.match?(~r/^\d.*/i, value) do
      true -> value
      false -> nil
    end
  end

  @num_obs 806
  @num_networks 1

  describe "list/0" do
    test "gets all the observations" do
      observations = RawObservationActions.list()
      assert length(observations) == @num_obs
    end
  end

  describe "list/1" do
    test "include_node, include_sensor, include_networks" do
      RawObservationActions.list(include_node: true, include_sensor: true, include_networks: true)
      |> Enum.each(fn obs ->
        assert Ecto.assoc_loaded?(obs.node)
        assert Ecto.assoc_loaded?(obs.sensor)
        assert Ecto.assoc_loaded?(obs.node.networks)
        assert length(obs.node.networks) == @num_networks
      end)
    end
  end
end
