defmodule Aot.SensorQueries do
  @moduledoc """
  Stored base queries and functions to compose queries for Sensors.
  """

  import Aot.QueryUtils, only: [
    apply_opts: 3
  ]

  import Ecto.Query

  alias Aot.{
    Network,
    NetworkSensor,
    Node,
    Sensor,
    SensorQueries
  }

  @spec list() :: Ecto.Queryable.t()
  def list, do: order_by(Sensor, [s], asc: s.path)

  @spec get(integer() | String.t()) :: Ecto.Queryable.t()
  def get(id), do: where(Sensor, [s], s.id == ^id or s.path == ^id)

  @spec with_networks(Ecto.Queryable.t()) :: Ecto.Queryable.t()
  def with_networks(query), do: preload(query, networks: :sensors)

  @spec with_nodes(Ecto.Queryable.t()) :: Ecto.Queryable.t()
  def with_nodes(query), do: preload(query, nodes: :sensors)

  @spec has_ontology(Ecto.Queryable.t(), String.t()) :: Ecto.Queryable.t()
  def has_ontology(query, ont), do: where(query, [s], s.ontology == ^ont)

  @spec observes_network(Ecto.Queryable.t(), Network.t() | integer() | String.t()) :: Ecto.Queryable.t()
  def observes_network(query, %Network{id: id}), do: observes_network(query, id)
  def observes_network(query, id), do: observes_networks(query, [id])

  @spec observes_networks(Ecto.Queryable.t(), list(Network.t() | integer() | String.t())) :: Ecto.Queryable.t()
  def observes_networks(query, networks) do
    network_ids =
      networks
      |> Enum.map(fn network ->
        case network do
          %Network{id: id} -> id
          id -> id
        end
      end)

    query
    |> join(:left, [s], ns in NetworkSensor, s.id == ns.sensor_id)
    |> join(:left, [ns], n in Network, ns.network_id == n.id)
    |> where([n], n.id in ^network_ids or n.slug in ^network_ids)
  end

  @spec onboard_node(Ecto.Queryable.t(), Node.t() | integer() | String.t()) :: Ecto.Queryable.t()
  def onboard_node(query, %Node{id: id}), do: onboard_node(query, id)
  def onboard_node(query, id), do: onboard_nodes(query, [id])

  @spec onboard_nodes(Ecto.Queryable.t(), list(Node.t() | integer() | String.t())) :: Ecto.Queryable.t()
  def onboard_nodes(query, nodes) do
    node_ids =
      nodes
      |> Enum.map(fn node ->
        case node do
          %Node{id: id} -> id
          id -> id
        end
      end)

    query
    |> join(:left, [s], ns in NodeSensor, s.id == ns.sensor_id)
    |> join(:left, [ns], n in Node, ns.node_id == n.id)
    |> where([n], n.id in ^node_ids or n.vsn in ^node_ids)
  end

  @spec handle_opts(Ecto.Queryable.t(), keyword()) :: Ecto.Queryable.t()
  def handle_opts(query, opts \\ []) do
    [
      with_networks: false,
      with_nodes: false,
      has_ontology: :empty,
      observes_network: :empty,
      observes_networks: :empty,
      onboard_node: :empty,
      onboard_nodes: :empty
    ]
    |> Keyword.merge(opts)
    |> apply_opts(query, SensorQueries)
  end
end
