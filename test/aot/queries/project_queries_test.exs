defmodule Aot.Testing.ProjectQueriesTest do
  use Aot.Testing.BaseCase
  use Aot.Testing.DataCase

  alias Aot.ProjectActions

  describe "has_nodes" do
    @tag add2ctx: :nodes
    test "projects don't need to have all nodes related", %{n004: n004, nDET1: nDET1} do
      projects = ProjectActions.list(has_nodes: [n004, nDET1])
      assert length(projects) == 2
    end
  end

  describe "has_nodes_exact" do
    @tag add2ctx: :nodes
    test "projects must have all nodes related", %{n004: n004, nDET1: nDET1} do
      projects = ProjectActions.list(has_nodes_exact: [n004, nDET1])
      assert length(projects) == 0
    end
  end

  describe "has_sensors" do
    @tag add2ctx: :sensors
    test "projects don't need to have all sensors related", %{h2s_concentration: s1, temperatures_ep_heatsink: s2} do
      projects = ProjectActions.list(has_sensors: [s1, s2])
      assert length(projects) == 3
    end
  end

  describe "has_sensors_exact" do
    @tag add2ctx: :sensors
    test "projects must have all sensors related", %{h2s_concentration: s1, temperatures_ep_heatsink: s2} do
      projects = ProjectActions.list(has_sensors_exact: [s1, s2])
      assert length(projects) == 3
    end
  end
end
