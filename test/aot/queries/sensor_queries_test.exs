defmodule Aot.Testing.SensorQueriesTest do
  use Aot.Testing.BaseCase
  use Aot.Testing.DataCase

  alias Aot.SensorActions

  describe "ontology" do
    test "will do an exact match" do
      ontology = "/sensing/meteorology/temperature"
      sensors = SensorActions.list(ontology: ontology)
      assert length(sensors) == 5
    end

    test "will do a prefix match" do
      ontology = "/sensing/meteorology"
      sensors = SensorActions.list(ontology: ontology)
      assert length(sensors) == 8
    end
  end

  describe "observes_networks" do
    @tag add2ctx: :networks
    test "sensors don't need to be present in every network", %{chicago: chi, portland: pdx} do
      sensors = SensorActions.list(observes_networks: [chi, pdx])
      assert length(sensors) == 107
    end
  end

  describe "observed_networks_exact" do
    @tag add2ctx: :networks
    test "sensors must be present in every network", %{chicago: chi, portland: pdx} do
      sensors = SensorActions.list(observes_networks_exact: [chi, pdx])
      assert length(sensors) == 107
    end
  end

  describe "onboard_nodes" do
    @tag add2ctx: :nodes
    test "sensors don't need to be on every node", %{n004: n004, nDET1: nDET1} do
      sensors = SensorActions.list(onboard_nodes: [n004, nDET1])
      assert length(sensors) == 25
    end
  end

  describe "onboard_nodes_exact" do
    @tag add2ctx: :nodes
    test "sensors need to be on every node", %{n004: n004, nDET1: nDET1} do
      sensors = SensorActions.list(onboard_nodes_exact: [n004, nDET1])
      assert length(sensors) == 0
    end
  end
end
