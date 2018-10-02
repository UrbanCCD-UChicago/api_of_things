defmodule Aot.Testing.M2MActionsTest do
  use Aot.Testing.DataCase

  alias Aot.{
    M2MActions,
    NetworkActions,
    NodeActions,
    SensorActions
  }

  @moduletag build: [:network, :node, :sensor]

  describe "create_network_node/1" do
    test "duplicate entries do not raise an error", %{network: network, node: node} do
      {:ok, _} = M2MActions.create_network_node(network: network, node: node)
      {:ok, _} = M2MActions.create_network_node(network: network, node: node)
    end

    test "using NetworkQueries.with_nodes/1 returns the associated nodes", %{network: network, node: node} do
      {:ok, _} = M2MActions.create_network_node(network: network, node: node)

      network = NetworkActions.get!(network.id, with_nodes: true)
      assert Ecto.assoc_loaded?(network.nodes)
      assert length(network.nodes) == 1
      em_node = List.first(network.nodes)
      assert em_node.id == node.id
    end

    test "using NodeQueries.with_networks/1 returns the associated networks", %{network: network, node: node} do
      {:ok, _} = M2MActions.create_network_node(network: network, node: node)

      node = NodeActions.get!(node.id, with_networks: true)
      assert Ecto.assoc_loaded?(node.networks)
      assert length(node.networks) == 1
      em_net = List.first(node.networks)
      assert em_net.id == network.id
    end
  end

  describe "create_network_sensor/1" do
    test "duplicate entries do not raise an error", %{network: network, sensor: sensor} do
      {:ok, _} = M2MActions.create_network_sensor(network: network, sensor: sensor)
      {:ok, _} = M2MActions.create_network_sensor(network: network, sensor: sensor)
    end

    test "using NetworkQueries.with_sensors/1 returns the associated sensors", %{network: network, sensor: sensor} do
      {:ok, _} = M2MActions.create_network_sensor(network: network, sensor: sensor)

      network = NetworkActions.get!(network.id, with_sensors: true)
      assert Ecto.assoc_loaded?(network.sensors)
      assert length(network.sensors) == 1
      em_sensor = List.first(network.sensors)
      assert em_sensor.id == sensor.id
    end

    test "using SensorQueries.with_networks/1 returns the associated networks", %{network: network, sensor: sensor} do
      {:ok, _} = M2MActions.create_network_sensor(network: network, sensor: sensor)

      sensor = SensorActions.get!(sensor.id, with_networks: true)
      assert Ecto.assoc_loaded?(sensor.networks)
      assert length(sensor.networks) == 1
      em_net = List.first(sensor.networks)
      assert em_net.id == network.id
    end
  end

  describe "create_node_sensor/1" do
    test "duplicate entries do not raise an error", %{node: node, sensor: sensor} do
      {:ok, _} = M2MActions.create_node_sensor(node: node, sensor: sensor)
      {:ok, _} = M2MActions.create_node_sensor(node: node, sensor: sensor)
    end

    test "using NodeQueries.with_sensors/1 returns the associated sensors", %{node: node, sensor: sensor} do
      {:ok, _} = M2MActions.create_node_sensor(node: node, sensor: sensor)

      node = NodeActions.get!(node.id, with_sensors: true)
      assert Ecto.assoc_loaded?(node.sensors)
      assert length(node.sensors) == 1
      em_net = List.first(node.sensors)
      assert em_net.id == sensor.id
    end

    test "using SensorQueries.with_nodes/1 returns the associated nodes", %{node: node, sensor: sensor} do
      {:ok, _} = M2MActions.create_node_sensor(node: node, sensor: sensor)

      sensor = SensorActions.get!(sensor.id, with_nodes: true)
      assert Ecto.assoc_loaded?(sensor.nodes)
      assert length(sensor.nodes) == 1
      em_net = List.first(sensor.nodes)
      assert em_net.id == node.id
    end
  end
end
