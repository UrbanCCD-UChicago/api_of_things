defmodule Aot.TestingNodeActionsTest do
  use Aot.Testing.DataCase

  alias Aot.NodeActions

  describe "create/1" do
    test "with a good id and vsn should create the location from the lon/lat args" do
      {:ok, node} = NodeActions.create(
        id: "0001abc24",
        vsn: "01A",
        longitude: -87.1231,
        latitude: 41.9812,
        commissioned_on: ~N[2018-04-21 15:00:00]
      )

      assert node.location == %Geo.Point{srid: 4326, coordinates: {-87.1231, 41.9812}}
    end

    @tag build: :node
    test "with a non-unique id should error", %{node: node} do
      {:error, changeset} =
        NodeActions.create(
          id: node.id,
          vsn: "013",
          longitude: 1,
          latitude: 2,
          commissioned_on: ~N[2018-04-21 15:00:00]
        )

      assert errors_on(changeset).id == ["has already been taken"]
    end

    @tag build: :node
    test "with a non-unique vsn should error", %{node: node} do
      {:error, changeset} =
        NodeActions.create(
          id: "001abc24",
          vsn: node.vsn,
          longitude: 1,
          latitude: 2,
          commissioned_on: ~N[2018-04-21 15:00:00]
        )

      assert errors_on(changeset).vsn == ["has already been taken"]
    end
  end

  describe "update/2" do
    @describetag build: :node

    test "with new lon or lat or both should reset the location", %{node: node} do
      {:ok, updated} = NodeActions.update(node, longitude: 1, latitude: 2)

      refute updated.location == node.location
      assert updated.location == %Geo.Point{srid: 4326, coordinates: {1.0, 2.0}}

      {:ok, up_lon} = NodeActions.update(updated, longitude: -1)
      assert up_lon.location == %Geo.Point{srid: 4326, coordinates: {-1.0, 2.0}}

      {:ok, up_lat} = NodeActions.update(up_lon, latitude: -2)
      assert up_lat.location == %Geo.Point{srid: 4326, coordinates: {-1.0, -2.0}}
    end

    test "with a non-unique id should error", %{node: node} do
      {:ok, other} = NodeActions.create(
        id: "0001abc24",
        vsn: "02A",
        longitude: -87.1231,
        latitude: 41.9812,
        commissioned_on: ~N[2018-04-21 15:00:00]
      )

      {:error, changeset} = NodeActions.update(node, id: other.id)
      assert errors_on(changeset).id == ["has already been taken"]
    end

    test "with a non-unique vsn should error", %{node: node} do
      {:ok, other} = NodeActions.create(
        id: "0001abc24",
        vsn: "02A",
        longitude: -87.1231,
        latitude: 41.9812,
        commissioned_on: ~N[2018-04-21 15:00:00]
      )

      {:error, changeset} = NodeActions.update(node, vsn: other.vsn)
      assert errors_on(changeset).vsn == ["has already been taken"]
    end
  end

  describe "get!/1" do
    @describetag build: :node

    test "with a known id", %{node: node} do
      found = NodeActions.get!(node.id)
      assert found.vsn == node.vsn
    end

    test "with a known vsn", %{node: node} do
      found = NodeActions.get!(node.vsn)
      assert found.id == node.id
    end

    test "with an unknown id/vsn should error" do
      assert_raise Ecto.NoResultsError, fn ->
        NodeActions.get!("i don't exist")
      end
    end
  end

  describe "get!/2" do
    @describetag build: :node

    test "using with_networks should embed a list of associated networks", %{node: node} do
      found = NodeActions.get!(node.id)
      refute Ecto.assoc_loaded?(found.networks)

      found = NodeActions.get!(node.id, with_networks: true)
      assert Ecto.assoc_loaded?(found.networks)
    end
  end

  describe "list/0" do
    @describetag build: :node

    test "should return all the nodes" do
      nodes = NodeActions.list()
      assert length(nodes) == 1
    end
  end

  describe "list/1" do
    @describetag build: :node

    test "using with_networks should embed a list of associated networks" do
      NodeActions.list()
      |> Enum.each(&refute Ecto.assoc_loaded?(&1.networks))

      NodeActions.list(with_networks: true)
      |> Enum.each(&assert Ecto.assoc_loaded?(&1.networks))
    end
  end
end
