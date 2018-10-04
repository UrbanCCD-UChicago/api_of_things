defmodule Aot.Testing.ObservationsCase do
  @moduledoc """
  This module defines setup for tests requiring loaded observation
  data. This will only load Observations -- if you are working with
  raw data, use the RawObservationsCase
  """

  use ExUnit.CaseTemplate

  alias Aot.{
    M2MActions,
    NetworkActions,
    NodeActions,
    ObservationActions,
    SensorActions,
  }

  using do
    quote do
      alias Aot.Repo
      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import Aot.Testing.DataCase
    end
  end

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
end
