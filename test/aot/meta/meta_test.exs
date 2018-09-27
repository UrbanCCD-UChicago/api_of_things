defmodule Aot.MetaTest do
  use Aot.DataCase

  alias Aot.Meta

  describe "networks" do
    alias Aot.Meta.Network

    @valid_attrs %{bbox: "some bbox", hull: "some hull", name: "some name", num_observations: 42, num_raw_observations: 42, slug: "some slug"}
    @update_attrs %{bbox: "some updated bbox", hull: "some updated hull", name: "some updated name", num_observations: 43, num_raw_observations: 43, slug: "some updated slug"}
    @invalid_attrs %{bbox: nil, hull: nil, name: nil, num_observations: nil, num_raw_observations: nil, slug: nil}

    def network_fixture(attrs \\ %{}) do
      {:ok, network} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Meta.create_network()

      network
    end

    test "list_networks/0 returns all networks" do
      network = network_fixture()
      assert Meta.list_networks() == [network]
    end

    test "get_network!/1 returns the network with given id" do
      network = network_fixture()
      assert Meta.get_network!(network.id) == network
    end

    test "create_network/1 with valid data creates a network" do
      assert {:ok, %Network{} = network} = Meta.create_network(@valid_attrs)
      assert network.bbox == "some bbox"
      assert network.hull == "some hull"
      assert network.name == "some name"
      assert network.num_observations == 42
      assert network.num_raw_observations == 42
      assert network.slug == "some slug"
    end

    test "create_network/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Meta.create_network(@invalid_attrs)
    end

    test "update_network/2 with valid data updates the network" do
      network = network_fixture()
      assert {:ok, network} = Meta.update_network(network, @update_attrs)
      assert %Network{} = network
      assert network.bbox == "some updated bbox"
      assert network.hull == "some updated hull"
      assert network.name == "some updated name"
      assert network.num_observations == 43
      assert network.num_raw_observations == 43
      assert network.slug == "some updated slug"
    end

    test "update_network/2 with invalid data returns error changeset" do
      network = network_fixture()
      assert {:error, %Ecto.Changeset{}} = Meta.update_network(network, @invalid_attrs)
      assert network == Meta.get_network!(network.id)
    end

    test "delete_network/1 deletes the network" do
      network = network_fixture()
      assert {:ok, %Network{}} = Meta.delete_network(network)
      assert_raise Ecto.NoResultsError, fn -> Meta.get_network!(network.id) end
    end

    test "change_network/1 returns a network changeset" do
      network = network_fixture()
      assert %Ecto.Changeset{} = Meta.change_network(network)
    end
  end

  describe "nodes" do
    alias Aot.Meta.Node

    @valid_attrs %{commissioned_on: ~N[2010-04-17 14:00:00.000000], decommissioned_on: ~N[2010-04-17 14:00:00.000000], description: "some description", human_address: "some human_address", id: "some id", location: "some location", vsn: "some vsn"}
    @update_attrs %{commissioned_on: ~N[2011-05-18 15:01:01.000000], decommissioned_on: ~N[2011-05-18 15:01:01.000000], description: "some updated description", human_address: "some updated human_address", id: "some updated id", location: "some updated location", vsn: "some updated vsn"}
    @invalid_attrs %{commissioned_on: nil, decommissioned_on: nil, description: nil, human_address: nil, id: nil, location: nil, vsn: nil}

    def node_fixture(attrs \\ %{}) do
      {:ok, node} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Meta.create_node()

      node
    end

    test "list_nodes/0 returns all nodes" do
      node = node_fixture()
      assert Meta.list_nodes() == [node]
    end

    test "get_node!/1 returns the node with given id" do
      node = node_fixture()
      assert Meta.get_node!(node.id) == node
    end

    test "create_node/1 with valid data creates a node" do
      assert {:ok, %Node{} = node} = Meta.create_node(@valid_attrs)
      assert node.commissioned_on == ~N[2010-04-17 14:00:00.000000]
      assert node.decommissioned_on == ~N[2010-04-17 14:00:00.000000]
      assert node.description == "some description"
      assert node.human_address == "some human_address"
      assert node.id == "some id"
      assert node.location == "some location"
      assert node.vsn == "some vsn"
    end

    test "create_node/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Meta.create_node(@invalid_attrs)
    end

    test "update_node/2 with valid data updates the node" do
      node = node_fixture()
      assert {:ok, node} = Meta.update_node(node, @update_attrs)
      assert %Node{} = node
      assert node.commissioned_on == ~N[2011-05-18 15:01:01.000000]
      assert node.decommissioned_on == ~N[2011-05-18 15:01:01.000000]
      assert node.description == "some updated description"
      assert node.human_address == "some updated human_address"
      assert node.id == "some updated id"
      assert node.location == "some updated location"
      assert node.vsn == "some updated vsn"
    end

    test "update_node/2 with invalid data returns error changeset" do
      node = node_fixture()
      assert {:error, %Ecto.Changeset{}} = Meta.update_node(node, @invalid_attrs)
      assert node == Meta.get_node!(node.id)
    end

    test "delete_node/1 deletes the node" do
      node = node_fixture()
      assert {:ok, %Node{}} = Meta.delete_node(node)
      assert_raise Ecto.NoResultsError, fn -> Meta.get_node!(node.id) end
    end

    test "change_node/1 returns a node changeset" do
      node = node_fixture()
      assert %Ecto.Changeset{} = Meta.change_node(node)
    end
  end

  describe "sensors" do
    alias Aot.Meta.Sensor

    @valid_attrs %{max_val: 120.5, min_val: 120.5, ontology: "some ontology", parameter: "some parameter", sensor: "some sensor", subsystem: "some subsystem", unit: "some unit"}
    @update_attrs %{max_val: 456.7, min_val: 456.7, ontology: "some updated ontology", parameter: "some updated parameter", sensor: "some updated sensor", subsystem: "some updated subsystem", unit: "some updated unit"}
    @invalid_attrs %{max_val: nil, min_val: nil, ontology: nil, parameter: nil, sensor: nil, subsystem: nil, unit: nil}

    def sensor_fixture(attrs \\ %{}) do
      {:ok, sensor} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Meta.create_sensor()

      sensor
    end

    test "list_sensors/0 returns all sensors" do
      sensor = sensor_fixture()
      assert Meta.list_sensors() == [sensor]
    end

    test "get_sensor!/1 returns the sensor with given id" do
      sensor = sensor_fixture()
      assert Meta.get_sensor!(sensor.id) == sensor
    end

    test "create_sensor/1 with valid data creates a sensor" do
      assert {:ok, %Sensor{} = sensor} = Meta.create_sensor(@valid_attrs)
      assert sensor.max_val == 120.5
      assert sensor.min_val == 120.5
      assert sensor.ontology == "some ontology"
      assert sensor.parameter == "some parameter"
      assert sensor.sensor == "some sensor"
      assert sensor.subsystem == "some subsystem"
      assert sensor.unit == "some unit"
    end

    test "create_sensor/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Meta.create_sensor(@invalid_attrs)
    end

    test "update_sensor/2 with valid data updates the sensor" do
      sensor = sensor_fixture()
      assert {:ok, sensor} = Meta.update_sensor(sensor, @update_attrs)
      assert %Sensor{} = sensor
      assert sensor.max_val == 456.7
      assert sensor.min_val == 456.7
      assert sensor.ontology == "some updated ontology"
      assert sensor.parameter == "some updated parameter"
      assert sensor.sensor == "some updated sensor"
      assert sensor.subsystem == "some updated subsystem"
      assert sensor.unit == "some updated unit"
    end

    test "update_sensor/2 with invalid data returns error changeset" do
      sensor = sensor_fixture()
      assert {:error, %Ecto.Changeset{}} = Meta.update_sensor(sensor, @invalid_attrs)
      assert sensor == Meta.get_sensor!(sensor.id)
    end

    test "delete_sensor/1 deletes the sensor" do
      sensor = sensor_fixture()
      assert {:ok, %Sensor{}} = Meta.delete_sensor(sensor)
      assert_raise Ecto.NoResultsError, fn -> Meta.get_sensor!(sensor.id) end
    end

    test "change_sensor/1 returns a sensor changeset" do
      sensor = sensor_fixture()
      assert %Ecto.Changeset{} = Meta.change_sensor(sensor)
    end
  end
end
