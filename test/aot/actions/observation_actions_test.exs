defmodule Aot.Testing.ObservationActionsTest do
  use Aot.Testing.ObservationsCase

  alias Aot.ObservationActions

  @num_obs 744
  @num_networks 1

  describe "list/0" do
    test "gets all the observations" do
      observations = ObservationActions.list()
      assert length(observations) == @num_obs
    end
  end

  describe "list/1" do
    test "include_node, include_sensor, include_networks" do
      ObservationActions.list(include_node: true, include_sensor: true, include_networks: true)
      |> Enum.each(fn obs ->
        assert Ecto.assoc_loaded?(obs.node)
        assert Ecto.assoc_loaded?(obs.sensor)
        assert Ecto.assoc_loaded?(obs.node.networks)
        assert length(obs.node.networks) == @num_networks
      end)
    end
  end
end
