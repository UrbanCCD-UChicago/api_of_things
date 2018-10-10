defmodule Aot.Testing.NetworkQueriesTest do
  use Aot.Testing.BaseCase
  use Aot.Testing.DataCase

  alias Aot.NetworkActions

  describe "has_nodes" do
    @tag add2ctx: :nodes
    test "networks don't need to have all nodes related", %{n001: node1, n005: node5} do
      networks = NetworkActions.list(has_nodes: [node1, node5])
      assert length(networks) == 2
    end
  end

  describe "has_nodes_exact" do
    @tag add2ctx: :nodes
    test "networks must have all nodes related", %{n001: node1, n005: node5} do
      networks = NetworkActions.list(has_nodes_exact: [node1, node5])
      assert length(networks) == 1
    end
  end

  describe "has_sensors" do
    @tag add2ctx: :sensors
    test "networks don't need to have all sensors related", %{onetemperature: s1, coconcentration: s2} do
      networks = NetworkActions.list(has_sensors: [s1, s2])
      assert length(networks) == 3
    end
  end

  describe "has_sensors_exact" do
    @tag add2ctx: :sensors
    test "networks must have all sensors related", %{onetemperature: s1, coconcentration: s2} do
      networks = NetworkActions.list(has_sensors_exact: [s1, s2])
      assert length(networks) == 1
    end
  end
end
