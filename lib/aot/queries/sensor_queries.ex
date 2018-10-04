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
    NodeSensor,
    Sensor,
    SensorQueries
  }

  @spec list() :: Ecto.Queryable.t()
  def list, do: Sensor

  @spec get(integer() | String.t()) :: Ecto.Queryable.t()
  def get(id) when is_integer(id), do: where(Sensor, [s], s.id == ^id)
  def get(id) when is_bitstring(id) do
    case Regex.match?(~r/^\d+$/, id) do
      true -> where(Sensor, [s], s.id == ^id)
      false -> where(Sensor, [s], s.path == ^id)
    end
  end

  @spec include_networks(Ecto.Queryable.t()) :: Ecto.Queryable.t()
  def include_networks(query), do: preload(query, networks: :sensors)

  @spec include_nodes(Ecto.Queryable.t()) :: Ecto.Queryable.t()
  def include_nodes(query), do: preload(query, nodes: :sensors)

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
      |> Enum.map(& "#{&1}")

    from s in query,
      left_join: ns in NetworkSensor, on: s.id == ns.sensor_id,
      left_join: n in Network, on: n.id == ns.network_id,
      where: fragment("?::text = ANY(?)", n.id, type(^network_ids, {:array, :string})) or n.slug in type(^network_ids, {:array, :string}),
      distinct: true
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

    from s in query,
      left_join: ns in NodeSensor, on: s.id == ns.sensor_id,
      left_join: n in Node, on: n.id == ns.node_id,
      where: n.id in type(^node_ids, {:array, :string}) or n.vsn in type(^node_ids, {:array, :string}),
      distinct: true
  end

  defdelegate order(query, args), to: Aot.QueryUtils
  defdelegate paginate(query, args), to: Aot.QueryUtils

  @spec handle_opts(Ecto.Queryable.t(), keyword()) :: Ecto.Queryable.t()
  def handle_opts(query, opts \\ []) do
    [
      include_networks: false,
      include_nodes: false,
      has_ontology: :empty,
      observes_network: :empty,
      observes_networks: :empty,
      onboard_node: :empty,
      onboard_nodes: :empty,
      order: :empty,
      paginate: :empty
    ]
    |> Keyword.merge(opts)
    |> apply_opts(query, SensorQueries)
  end
end
