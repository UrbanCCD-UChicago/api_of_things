defmodule Aot.Testing.CompleteMetaCase do
  @moduledoc """
  This module defines setup for tests requiring access to a complete
  suite of networks, nodes and sensors.

  This does not include any observation data.

  Furthermore, this module uses `setup_all` to speed up the tests --
  you should not perform any mutative or destructive action against
  the records when using this module.
  """

  use ExUnit.CaseTemplate

  alias Aot.{
    M2MActions,
    NetworkActions,
    NodeActions,
    SensorActions
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

  setup_all do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Aot.Repo)
    :ok = Ecto.Adapters.SQL.Sandbox.mode(Aot.Repo, {:shared, self()})

    poly1 = %Geo.Polygon{
      srid: 4326,
      coordinates: [[
        {-87, 41},
        {-87, 43},
        {-89, 43},
        {-89, 41},
        {-87, 41}
      ]]
    }

    poly2 = %Geo.Polygon{
      srid: 4326,
      coordinates: [[
        {-98, 35},
        {-98, 36},
        {-99, 36},
        {-99, 35},
        {-98, 35}
      ]]
    }

    {:ok, net1} =
      NetworkActions.create(
        name: "Chicago Public",
        archive_url: "https://example.com/a1",
        recent_url: "https://example.com/r1",
        first_observation: ~N[2018-01-01 00:00:00],
        latest_observation: NaiveDateTime.utc_now(),
        bbox: poly1,
        hull: poly1
      )
    {:ok, net2} =
      NetworkActions.create(
        name: "Chicago Complete",
        archive_url: "https://example.com/a2",
        recent_url: "https://example.com/r2",
        first_observation: ~N[2018-01-01 00:00:00],
        latest_observation: NaiveDateTime.utc_now(),
        bbox: poly1,
        hull: poly1
      )
    {:ok, net3} =
      NetworkActions.create(
        name: "Denver Complete",
        archive_url: "https://example.com/a3",
        recent_url: "https://example.com/r3",
        first_observation: ~N[2018-06-01 00:00:00],
        latest_observation: NaiveDateTime.utc_now(),
        bbox: poly2,
        hull: poly2
      )

    {:ok, node1} =
      NodeActions.create(
        id: "000123abc",
        vsn: "01A",
        longitude: -87.1234,
        latitude: 41.4321,
        commissioned_on: ~N[2018-04-21 15:00:00]
      )
    {:ok, node2} =
      NodeActions.create(
        id: "000123abd",
        vsn: "01B",
        longitude: -87.1235,
        latitude: 41.4322,
        commissioned_on: ~N[2018-01-01 00:00:00]
      )
    {:ok, node3} =
      NodeActions.create(
        id: "000123abe",
        vsn: "01C",
        longitude: -98.1234,
        latitude: 35.4321,
        commissioned_on: ~N[2018-01-01 00:00:00]
      )

    {:ok, sensor1} =
      SensorActions.create(
        ontology: "/sensing/physical/temperature",
        subsystem: "metsense",
        sensor: "htu21d",
        parameter: "temperature"
      )
    {:ok, sensor2} =
      SensorActions.create(
        ontology: "/sensing/physical/temperature",
        subsystem: "metsense",
        sensor: "tsys01",
        parameter: "temperature"
      )
    {:ok, sensor3} =
      SensorActions.create(
        ontology: "/sensing/atmosphere/co",
        subsystem: "chemsense",
        sensor: "co",
        parameter: "concentration"
      )

    {:ok, _} = M2MActions.create_network_node(network: net1, node: node1)
    {:ok, _} = M2MActions.create_network_node(network: net1, node: node2)
    {:ok, _} = M2MActions.create_network_node(network: net2, node: node1)
    {:ok, _} = M2MActions.create_network_node(network: net2, node: node2)
    {:ok, _} = M2MActions.create_network_node(network: net3, node: node3)

    {:ok, _} = M2MActions.create_node_sensor(node: node1, sensor: sensor1)
    {:ok, _} = M2MActions.create_node_sensor(node: node1, sensor: sensor2)
    {:ok, _} = M2MActions.create_node_sensor(node: node1, sensor: sensor3)
    {:ok, _} = M2MActions.create_node_sensor(node: node2, sensor: sensor1)
    {:ok, _} = M2MActions.create_node_sensor(node: node2, sensor: sensor2)
    {:ok, _} = M2MActions.create_node_sensor(node: node2, sensor: sensor3)
    {:ok, _} = M2MActions.create_node_sensor(node: node3, sensor: sensor1)
    {:ok, _} = M2MActions.create_node_sensor(node: node3, sensor: sensor2)

    {:ok, _} = M2MActions.create_network_sensor(network: net1, sensor: sensor1)
    {:ok, _} = M2MActions.create_network_sensor(network: net1, sensor: sensor2)
    {:ok, _} = M2MActions.create_network_sensor(network: net1, sensor: sensor3)
    {:ok, _} = M2MActions.create_network_sensor(network: net2, sensor: sensor1)
    {:ok, _} = M2MActions.create_network_sensor(network: net2, sensor: sensor2)
    {:ok, _} = M2MActions.create_network_sensor(network: net2, sensor: sensor3)
    {:ok, _} = M2MActions.create_network_sensor(network: net3, sensor: sensor1)
    {:ok, _} = M2MActions.create_network_sensor(network: net3, sensor: sensor2)

    {:ok, net1: net1, net2: net2, net3: net3, node1: node1, node2: node2, node3: node3, sensor1: sensor1, sensor2: sensor2, sensor3: sensor3}
  end
end
