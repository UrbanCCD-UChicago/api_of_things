defmodule Aot.Testing.RawObservationActionsTest do
  use Aot.Testing.RawObservationsCase

  alias Aot.RawObservationActions

  @num_obs 806
  @num_networks 1

  describe "list/0" do
    test "gets all the observations" do
      observations = RawObservationActions.list()
      assert length(observations) == @num_obs
    end
  end

  describe "list/1" do
    test "include_node, include_sensor, include_networks" do
      RawObservationActions.list(include_node: true, include_sensor: true, include_networks: true)
      |> Enum.each(fn obs ->
        assert Ecto.assoc_loaded?(obs.node)
        assert Ecto.assoc_loaded?(obs.sensor)
        assert Ecto.assoc_loaded?(obs.node.networks)
        assert length(obs.node.networks) == @num_networks
      end)
    end
  end
end
