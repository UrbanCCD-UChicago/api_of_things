defmodule Aot.Testing.NodeQueriesTest do
  use Aot.Testing.BaseCase
  use Aot.Testing.DataCase

  alias Aot.NodeActions

  describe "within_networks" do
    @tag add2ctx: :networks
    test "nodes don't need to be in every networks", %{chicago_complete: chic, chicago_public: chip} do
      nodes = NodeActions.list(within_networks: [chic, chip])
      assert length(nodes) == 5
    end
  end

  describe "within_networks_exact" do
    @tag add2ctx: :networks
    test "nodes need to be in every network", %{chicago_complete: chic, chicago_public: chip} do
      nodes = NodeActions.list(within_networks_exact: [chic, chip])
      assert length(nodes) == 1
    end
  end

  describe "has_sensors" do
    @tag add2ctx: :sensors
    test "nodes don't need all the sensors to be onboard", %{onetemperature: s1, coconcentration: s2} do
      nodes = NodeActions.list(has_sensors: [s1, s2])
      assert length(nodes) == 6
    end
  end

  describe "has_sensors_exact" do
    @tag add2ctx: :sensors
    test "nodes required to have every sensor onboard", %{onetemperature: s1, coconcentration: s2} do
      nodes = NodeActions.list(has_sensors_exact: [s1, s2])
      assert length(nodes) == 4
    end
  end
end
