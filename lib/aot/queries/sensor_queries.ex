defmodule Aot.SensorQueries do
  @moduledoc """
  """

  import Aot.QueryUtils, only: [
    boolean_compose: 4,
    filter_compose: 4
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

  # BASE QUERIES

  @spec list() :: Ecto.Queryable.t()
  def list,
    do: from sensor in Sensor

  @spec get(binary()) :: Ecto.Queryable.t()
  def get(path),
    do: from sensor in Sensor,
      where: sensor.path == ^path

  # BOOLEAN COMPOSE

  @spec include_networks(Ecto.Queryable.t()) :: Ecto.Queryable.t()
  def include_networks(query),
    do: from sensor in query,
      preload: [networks: :sensors]

  @spec include_nodes(Ecto.Queryable.t()) :: Ecto.Queryable.t()
  def include_nodes(query),
    do: from sensor in query,
      preload: [nodes: :sensors]

  # FILTER COMPOSE

  @spec ontology(Ecto.Queryable.t(), any()) :: Ecto.Queryable.t()
  def ontology(query, ontology) do
    padded = "%#{ontology}%"

    from sensor in query,
      where: fragment("? like ?", sensor.ontology, ^padded)
  end

  @spec observes_network(Ecto.Queryable.t(), binary() | Aot.Network.t()) :: Ecto.Queryable.t()
  def observes_network(query, %Network{slug: slug}),
    do: observes_network(query, slug)

  def observes_network(query, slug) when is_binary(slug),
    do: observes_networks(query, [slug])

  @spec observes_networks(Ecto.Queryable.t(), maybe_improper_list()) :: Ecto.Queryable.t()
  def observes_networks(query, networks) when is_list(networks) do
    slugs =
      networks
      |> Enum.map(fn net ->
        case net do
          %Network{} -> net.slug
          slug -> slug
        end
      end)

    from sensor in query,
      left_join: nes in NetworkSensor, as: :nes, on: nes.sensor_path == sensor.path,
      left_join: net in Network, as: :net, on: nes.network_slug == net.slug,
      where: net.slug in ^slugs,
      distinct: true
  end

  @spec observes_networks_exact(Ecto.Queryable.t(), maybe_improper_list()) :: Ecto.Queryable.t()
  def observes_networks_exact(query, networks) when is_list(networks) do
    slugs =
      networks
      |> Enum.map(fn net ->
        case net do
          %Network{} -> net.slug
          slug -> slug
        end
      end)

    from sensor in query,
      left_join: nes in NetworkSensor, as: :nes, on: nes.sensor_path == sensor.path,
      left_join: net in Network, as: :net, on: nes.network_slug == net.slug,
      group_by: sensor.path,
      having: fragment("array_agg(?) @> ?", net.slug, ^slugs)
  end

  @spec onboard_node(Ecto.Queryable.t(), binary() | Aot.Node.t()) :: Ecto.Queryable.t()
  def onboard_node(query, %Node{id: id}),
    do: onboard_node(query, id)

  def onboard_node(query, id) when is_binary(id),
    do: onboard_nodes(query, [id])

  @spec onboard_nodes(Ecto.Queryable.t(), maybe_improper_list()) :: Ecto.Queryable.t()
  def onboard_nodes(query, nodes) when is_list(nodes) do
    ids =
      nodes
      |> Enum.map(fn node ->
        case node do
          %Node{} -> node.id
          id -> id
        end
      end)

    from sensor in query,
      left_join: nos in NodeSensor, as: :nos, on: nos.sensor_path == sensor.path,
      left_join: node in Node, as: :node, on: nos.node_id == node.id,
      where: node.id in ^ids,
      distinct: true
  end

  @spec onboard_nodes_exact(Ecto.Queryable.t(), maybe_improper_list()) :: Ecto.Queryable.t()
  def onboard_nodes_exact(query, nodes) when is_list(nodes) do
    ids =
      nodes
      |> Enum.map(fn node ->
        case node do
          %Node{} -> node.id
          id -> id
        end
      end)

    from sensor in query,
      left_join: nos in NodeSensor, as: :nos, on: nos.sensor_path == sensor.path,
      left_join: node in Node, as: :node, on: nos.node_id == node.id,
      group_by: sensor.path,
      having: fragment("array_agg(?) @> ?", node.id, ^ids)
  end

  defdelegate order(query, args), to: Aot.QueryUtils
  defdelegate paginate(query, args), to: Aot.QueryUtils

  # OTHER ACTION HELPERS

  @spec handle_opts(Ecto.Queryable.t(), keyword()) :: Ecto.Queryable.t()
  def handle_opts(query, opts \\ []) do
    opts =
      [
        include_networks: false,
        include_nodes: false,
        ontology: :empty,
        observes_network: :empty,
        observes_networks: :empty,
        observes_networks_exact: :empty,
        onboard_node: :empty,
        onboard_nodes: :empty,
        onboard_nodes_exact: :empty,
        order: :empty,
        paginate: :empty
      ]
      |> Keyword.merge(opts)

    query
    |> boolean_compose(opts[:include_networks], SensorQueries, :include_networks)
    |> boolean_compose(opts[:include_nodes], SensorQueries, :include_nodes)
    |> filter_compose(opts[:ontology], SensorQueries, :ontology)
    |> filter_compose(opts[:observes_network], SensorQueries, :observes_network)
    |> filter_compose(opts[:observes_networks], SensorQueries, :observes_networks)
    |> filter_compose(opts[:observes_networks_exact], SensorQueries, :observes_networks_exact)
    |> filter_compose(opts[:onboard_node], SensorQueries, :onboard_node)
    |> filter_compose(opts[:onboard_nodes], SensorQueries, :onboard_nodes)
    |> filter_compose(opts[:onboard_nodes_exact], SensorQueries, :onboard_nodes_exact)
    |> filter_compose(opts[:order], SensorQueries, :order)
    |> filter_compose(opts[:paginate], SensorQueries, :paginate)
  end
end
