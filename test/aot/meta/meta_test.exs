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
end
