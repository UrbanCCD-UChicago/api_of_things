defmodule Aot.Testing.NodeQueriesTest do
  use Aot.Testing.BaseCase
  use Aot.Testing.DataCase

  alias Aot.NodeActions

  describe "within_projects" do
    @tag add2ctx: :projects
    test "nodes don't need to be in every projects", %{chicago: chic, portland: pdx} do
      nodes = NodeActions.list(within_projects: [chic, pdx])
      assert length(nodes) == 94
    end
  end

  describe "within_projects_exact" do
    @tag add2ctx: :projects
    test "nodes need to be in every project", %{chicago: chic, portland: pdx} do
      nodes = NodeActions.list(within_projects_exact: [chic, pdx])
      assert length(nodes) == 0
    end
  end

  describe "has_sensors" do
    @tag add2ctx: :sensors
    test "nodes don't need all the sensors to be onboard", %{h2s_concentration: s1, bmp180_pressure: s2} do
      nodes = NodeActions.list(has_sensors: [s1, s2])
      assert length(nodes) == 42
    end
  end

  describe "has_sensors_exact" do
    @tag add2ctx: :sensors
    test "nodes required to have every sensor onboard", %{h2s_concentration: s1, bmp180_pressure: s2} do
      nodes = NodeActions.list(has_sensors_exact: [s1, s2])
      assert length(nodes) == 22
    end
  end
end
