defmodule Aot.Data do
  import Ecto.Query, warn: false

  alias Aot.Repo

  alias Aot.Data.{
      Observation,
      RawObservation
  }

  alias Aot.Meta.{
      Node,
      Sensor,
      Network,
      NetworksNodes
  }

  # OBSERVATION QUERY HELPERS

  def for_node(query, %Node{id: id}), do: for_node(query, id)
  def for_node(query, id), do: where(query, [o], o.node_id == ^id)

  def for_nodes(query, nodes) do
    node_ids =
      nodes
      |> Enum.map(fn node ->
        case node do
            %Node{id: id} -> id
            id -> id
        end
      end)

    where(query, [o], o.node_id in ^node_ids)
  end

  def for_sensor(query, %Sensor{id: id}), do: for_sensor(query, id)
  def for_sensor(query, id), do: where(query, [o], o.sensor_id == ^id)

  def for_sensors(query, sensors) do
    sensor_ids =
      sensors
      |> Enum.map(fn sensor ->
        case sensor do
            %Sensor{id: id} -> id
            id -> id
        end
      end)

    where(query, [o], o.sensor_id in ^sensor_ids)
  end

  def in_network(query, %Network{id: id}), do: in_network(query, id)
  def in_network(query, id) do
    query
    |> join(:left, [o], n in Node, o.node_id == n.id)
    |> join(:left, [n], nn in NetworksNodes, n.id == nn.node_id)
    |> join(:left, [nn], e in Network, nn.network_id == e.id)
    |> where([e], e.id == ^id)
  end

  # OBSERVATION ACTIONS

  def list_observations

  def create_observation(attrs \\ %{}) do
    %Observation{}
    |> Observation.changeset(attrs)
    |> Repo.insert(on_conflict: :nothing)
  end

  # RAW OBSERVATION QUERY HELPERS

  # RAW OBSERVATION ACTIONS

  def list_raw_observations

  def create_raw_observation(attrs \\ %{}) do
    %RawObservation{}
    |> RawObservation.changeset(attrs)
    |> Repo.insert(on_conflict: :nothing)
  end
end
