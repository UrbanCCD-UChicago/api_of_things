defmodule Aot.Testing.NetworkQueriesTest do
  use Aot.Testing.BaseCase
  use Aot.Testing.DataCase

  alias Aot.NetworkActions

  describe "has_nodes" do
    @tag add2ctx: :nodes
    test "networks don't need to have all nodes related", %{n004: n004, nDET1: nDET1} do
      networks = NetworkActions.list(has_nodes: [n004, nDET1])
      assert length(networks) == 2
    end
  end

  describe "has_nodes_exact" do
    @tag add2ctx: :nodes
    test "networks must have all nodes related", %{n004: n004, nDET1: nDET1} do
      networks = NetworkActions.list(has_nodes_exact: [n004, nDET1])
      assert length(networks) == 0
    end
  end

  describe "has_sensors" do
    @tag add2ctx: :sensors
    test "networks don't need to have all sensors related", %{h2s_concentration: s1, temperatures_ep_heatsink: s2} do
      networks = NetworkActions.list(has_sensors: [s1, s2])
      assert length(networks) == 3
    end
  end

  describe "has_sensors_exact" do
    @tag add2ctx: :sensors
    test "networks must have all sensors related", %{h2s_concentration: s1, temperatures_ep_heatsink: s2} do
      networks = NetworkActions.list(has_sensors_exact: [s1, s2])
      assert length(networks) == 3
    end
  end
end
