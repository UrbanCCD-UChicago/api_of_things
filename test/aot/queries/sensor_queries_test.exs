defmodule Aot.Testing.SensorQueriesTest do
  use Aot.Testing.BaseCase

  alias Aot.SensorActions

  test "include_networks/1" do
    SensorActions.list()
    |> Enum.each(& refute Ecto.assoc_loaded?(&1.networks))

    SensorActions.list(include_networks: true)
    |> Enum.each(& assert Ecto.assoc_loaded?(&1.networks))
  end

  test "include_nodes/1" do
    SensorActions.list()
    |> Enum.each(& refute Ecto.assoc_loaded?(&1.nodes))

    SensorActions.list(include_nodes: true)
    |> Enum.each(& assert Ecto.assoc_loaded?(&1.nodes))
  end

  test "has_ontology/2" do
    sensors = SensorActions.list(has_ontology: "/sensing/air_quality/gases/co")
    assert length(sensors) == 1

    sensors = SensorActions.list(has_ontology: "/sensing/meteorology/humidity")
    assert length(sensors) == 2
  end

  @tag add2ctx: :networks
  test "observes_networks/2", %{chicago_complete: chic, denver: denver} do
    sensors = SensorActions.list(observes_networks: [chic, denver])
    assert length(sensors) == 13
  end

  @tag add2ctx: :nodes
  test "onboard_nodes/2", %{n004: n004, n000: n000} do
    sensors = SensorActions.list(onboard_nodes: [n004, n000])
    assert length(sensors) == 13
  end

  @tag add2ctx: [:nodes, :sensors]
  test "handle_opts/2", %{n004: n004, s11: s11, s12: s12} do
    sensors =
      SensorActions.list(
        include_networks: true,
        include_nodes: true,
        onboard_node: n004,
        has_ontology: "/sensing/meteorology/humidity"
      )

    assert Enum.map(sensors, & &1.id) == [s11.id, s12.id]
    assert Enum.each(sensors, & assert Ecto.assoc_loaded?(&1.networks))
    assert Enum.each(sensors, & assert Ecto.assoc_loaded?(&1.nodes))
  end
end
