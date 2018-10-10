defmodule Aot.SensorQueries do
  @moduledoc """
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

  # BASE QUERIES

  def list,
    do: from sensor in Sensor

  def get(path),
    do: from sensor in Sensor,
      where: sensor.path == ^path

  # BOOLEAN COMPOSE

  def include_networks(query),
    do: from sensor in query,
      preload: [networks: :sensors]

  def include_nodes(query),
    do: from sensor in query,
      preload: [nodes: :sensors]

  # FILTER COMPOSE

  def ontology(query, ontology) do
    padded = "%#{ontology}%"

    from sensor in query,
      where: fragment("? like ?", sensor.ontology, ^padded)
  end

  def observes_network(query, %Network{slug: slug}),
    do: observes_network(query, slug)

  def observes_network(query, slug) when is_binary(slug),
    do: observes_networks(query, [slug])

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
      where: net.slug in ^slugs
  end

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

  def onboard_node(query, %Node{id: id}),
    do: onboard_node(query, id)

  def onboard_node(query, id) when is_binary(id),
    do: onboard_nodes(query, [id])

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
      where: node.id in ^ids
  end

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

  def handle_opts(query, opts \\ []) do
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
    |> apply_opts(query, SensorQueries)
  end
end
