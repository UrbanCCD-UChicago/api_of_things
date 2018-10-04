defmodule Aot.Testing.NetworkActionsTest do
  use Aot.Testing.DataCase

  alias Aot.NetworkActions

  describe "create/1" do
    test "with good name, archive and recent url values should generate a slug" do
      {:ok, net} = NetworkActions.create(
        name: "Some Network",
        archive_url: "https://example.com/arch1",
        recent_url: "https://example.com/rec1"
      )

      refute net.slug == nil
      assert net.slug == "some-network"
    end

    @tag build: :network
    test "with a non-unique name should error", %{network: net} do
      {:error, changeset} = NetworkActions.create(
        name: net.name,
        archive_url: "https://example.com/arch1",
        recent_url: "https://example.com/rec1"
      )

      assert errors_on(changeset).name == ["has already been taken"]
    end

    @tag build: :network
    test "with a non-unique archive url should error", %{network: net} do
      {:error, changeset} = NetworkActions.create(
        name: "Some Network",
        archive_url: net.archive_url,
        recent_url: "https://example.com/rec1"
      )

      assert errors_on(changeset).archive_url == ["has already been taken"]
    end

    @tag build: :network
    test "with a non-unique recent url should error", %{network: net} do
      {:error, changeset} = NetworkActions.create(
        name: "Some Network",
        archive_url: "https://example.com/arch1",
        recent_url: net.recent_url
      )

      assert errors_on(changeset).recent_url == ["has already been taken"]
    end

    test "with a non-https archive url should error" do
      {:error, changeset} = NetworkActions.create(
        name: "Some Network",
        archive_url: "http://example.com/arch1",
        recent_url: "https://example.com/rec1"
      )

      assert errors_on(changeset).archive_url == ["has invalid format"]
    end

    test "with a non-https recent url should error" do
      {:error, changeset} = NetworkActions.create(
        name: "Some Network",
        archive_url: "https://example.com/arch1",
        recent_url: "http://example.com/rec1"
      )

      assert errors_on(changeset).recent_url == ["has invalid format"]
    end
  end

  describe "update/2" do
    @describetag build: :network

    test "a change in name changes the slug", %{network: net} do
      {:ok, updated} = NetworkActions.update(net, name: "Some Network")

      refute updated.slug == net.slug
      assert updated.slug == "some-network"
    end

    test "to a non-unique name should error", %{network: net} do
      {:ok, other} = NetworkActions.create(
        name: "Some Network",
        archive_url: "https://example.com/arch1",
        recent_url: "https://example.com/rec1"
      )

      {:error, changeset} = NetworkActions.update(net, name: other.name)
      assert errors_on(changeset).name == ["has already been taken"]
    end

    test "to a non-unique archive url should error", %{network: net} do
      {:ok, other} = NetworkActions.create(
        name: "Some Network",
        archive_url: "https://example.com/arch1",
        recent_url: "https://example.com/rec1"
      )

      {:error, changeset} = NetworkActions.update(net, archive_url: other.archive_url)
      assert errors_on(changeset).archive_url == ["has already been taken"]
    end

    test "to a non-unique recent url should error", %{network: net} do
      {:ok, other} = NetworkActions.create(
        name: "Some Network",
        archive_url: "https://example.com/arch1",
        recent_url: "https://example.com/rec1"
      )

      {:error, changeset} = NetworkActions.update(net, recent_url: other.recent_url)
      assert errors_on(changeset).recent_url == ["has already been taken"]
    end

    test "to a non-https archive url should error", %{network: net} do
      {:error, changeset} = NetworkActions.update(net, archive_url: "http://example.com/")
      assert errors_on(changeset).archive_url == ["has invalid format"]
    end

    test "to a non-https recent url should error", %{network: net} do
      {:error, changeset} = NetworkActions.update(net, recent_url: "http://example.com/")
      assert errors_on(changeset).recent_url == ["has invalid format"]
    end
  end

  describe "get!/1" do
    @describetag build: :network

    test "with a known id", %{network: net} do
      found = NetworkActions.get!(net.id)
      assert found.slug == net.slug
    end

    test "with a known slug", %{network: net} do
      found = NetworkActions.get!(net.slug)
      assert found.id == net.id
    end

    test "with an unknown id should raise and error" do
      assert_raise Ecto.NoResultsError, fn ->
        NetworkActions.get!(123456789)
      end
    end

    test "with an unknown slug should raise and error" do
      assert_raise Ecto.NoResultsError, fn ->
        NetworkActions.get!("i-dont-exist")
      end
    end
  end

  describe "get!/2" do
    @describetag build: :network

    test "using include_nodes will embed a list of associated nodes", %{network: net} do
      found = NetworkActions.get!(net.id)
      refute Ecto.assoc_loaded?(found.nodes)

      found = NetworkActions.get!(net.id, include_nodes: true)
      assert Ecto.assoc_loaded?(found.nodes)
    end
  end

  describe "list/0" do
    @describetag build: :network

    test "it gets all the networks" do
      nets = NetworkActions.list()
      assert length(nets) == 1
    end
  end

  describe "list/1" do
    @describetag build: :network

    test "using include_nodes will embed a list of associated nodes for each network" do
      NetworkActions.list()
      |> Enum.each(&refute Ecto.assoc_loaded?(&1.nodes))

      NetworkActions.list(include_nodes: true)
      |> Enum.each(&assert Ecto.assoc_loaded?(&1.nodes))
    end
  end
end
