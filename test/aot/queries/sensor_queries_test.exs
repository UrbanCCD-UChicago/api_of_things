defmodule Aot.Testing.SensorQueriesTest do
  use Aot.Testing.CompleteMetaCase

  alias Aot.SensorActions

  test "with_networks/1" do
    SensorActions.list()
    |> Enum.each(& refute Ecto.assoc_loaded?(&1.networks))

    SensorActions.list(with_networks: true)
    |> Enum.each(& assert Ecto.assoc_loaded?(&1.networks))
  end

  test "with_nodes/1" do
    SensorActions.list()
    |> Enum.each(& refute Ecto.assoc_loaded?(&1.nodes))

    SensorActions.list(with_nodes: true)
    |> Enum.each(& assert Ecto.assoc_loaded?(&1.nodes))
  end

  test "has_ontology/2", %{sensor1: sensor1, sensor2: sensor2} do
    sensor_ids =
      SensorActions.list(has_ontology: "/sensing/physical/temperature")
      |> Enum.map(& &1.id)

    assert length(sensor_ids) == 2

    [sensor1.id, sensor2.id]
    |> Enum.each(& assert Enum.member?(sensor_ids, &1))
  end

  test "observes_network/2", %{net3: net3, sensor1: sensor1, sensor2: sensor2} do
    sensor_ids =
      SensorActions.list(observes_network: net3)
      |> Enum.map(& &1.id)

    assert length(sensor_ids) == 2

    [sensor1.id, sensor2.id]
    |> Enum.each(& assert Enum.member?(sensor_ids, &1))
  end

  test "observes_networks/2", %{net1: net1, net3: net3, sensor1: sensor1, sensor2: sensor2, sensor3: sensor3} do
    sensor_ids =
      SensorActions.list(observes_networks: [net1, net3])
      |> Enum.map(& &1.id)

    assert length(sensor_ids) == 3

    [sensor1.id, sensor2.id, sensor3.id]
    |> Enum.each(& assert Enum.member?(sensor_ids, &1))
  end

  test "onboard_node/2", %{node3: node3, sensor1: sensor1, sensor2: sensor2} do
    sensor_ids =
      SensorActions.list(onboard_node: node3)
      |> Enum.map(& &1.id)

    assert length(sensor_ids) == 2

    [sensor1.id, sensor2.id]
    |> Enum.each(& assert Enum.member?(sensor_ids, &1))
  end

  test "onboard_nodes/2", %{node1: node1, node2: node2, sensor1: sensor1, sensor2: sensor2, sensor3: sensor3} do
    sensor_ids =
      SensorActions.list(onboard_nodes: [node1, node2])
      |> Enum.map(& &1.id)

    assert length(sensor_ids) == 3

    [sensor1.id, sensor2.id, sensor3.id]
    |> Enum.each(& assert Enum.member?(sensor_ids, &1))
  end

  test "handle_opts/2", %{node1: node1, sensor1: sensor1, sensor2: sensor2} do
    sensors =
      SensorActions.list(
        with_networks: true,
        with_nodes: true,
        onboard_node: node1,
        has_ontology: "/sensing/physical/temperature"
      )

    assert Enum.map(sensors, & &1.id) == [sensor1.id, sensor2.id]
    assert Enum.each(sensors, & assert Ecto.assoc_loaded?(&1.networks))
    assert Enum.each(sensors, & assert Ecto.assoc_loaded?(&1.nodes))
  end
end
