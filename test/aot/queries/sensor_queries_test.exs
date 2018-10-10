defmodule Aot.Testing.SensorQueriesTest do
  use Aot.Testing.BaseCase
  use Aot.Testing.DataCase

  alias Aot.SensorActions

  describe "ontology" do
    test "will do an exact match" do
      ontology = "/sensing/meteorology/temperature"
      sensors = SensorActions.list(ontology: ontology)
      assert length(sensors) == 2
    end

    test "will do a prefix match" do
      ontology = "/sensing/meteorology"
      sensors = SensorActions.list(ontology: ontology)
      assert length(sensors) == 3
    end
  end

  describe "observes_networks" do
    @tag add2ctx: :networks
    test "sensors don't need to be present in every network", %{chicago_complete: chic, denver_complete: den} do
      sensors = SensorActions.list(observes_networks: [chic, den])
      assert length(sensors) == 6
    end
  end

  describe "observed_networks_exact" do
    @tag add2ctx: :networks
    test "sensors must be present in every network", %{chicago_complete: chic, denver_complete: den} do
      sensors = SensorActions.list(observes_networks_exact: [chic, den])
      assert length(sensors) == 3
    end
  end

  describe "onboard_nodes" do
    @tag add2ctx: :nodes
    test "sensors don't need to be on every node", %{n001: node1, n005: node5} do
      sensors = SensorActions.list(onboard_nodes: [node1, node5])
      assert length(sensors) == 6
    end
  end

  describe "onboard_nodes_exact" do
    @tag add2ctx: :nodes
    test "sensors need to be on every node", %{n001: node1, n005: node5} do
      sensors = SensorActions.list(onboard_nodes_exact: [node1, node5])
      assert length(sensors) == 3
    end
  end
end
