defmodule Aot.NetworkQueries do
  @moduledoc """
  """

  import Aot.QueryUtils, only: [
    apply_opts: 3
  ]

  import Ecto.Query

  import Geo.PostGIS, only: [
    st_contains: 2,
    st_convex_hull: 1,
    st_envelope: 1,
    st_intersects: 2,
    st_union: 1
  ]

  alias Aot.{
    Network,
    NetworkNode,
    NetworkQueries,
    NetworkSensor,
    Node,
    Sensor
  }

  # BASE QUERIES

  def list,
    do: from net in Network

  def get(slug),
    do: from net in Network,
      where: net.slug == ^slug

  # BOOLEAN COMPOSE

  def include_nodes(query),
    do: from net in query,
      preload: [nodes: :networks]

  def include_sensors(query),
    do: from net in query,
      preload: [sensors: :networks]

  # FILTER COMPOSE

  def has_node(query, %Node{id: id}),
    do: has_node(query, id)

  def has_node(query, id) when is_binary(id),
    do: has_nodes(query, [id])

  def has_nodes(query, nodes) when is_list(nodes) do
    ids =
      nodes
      |> Enum.map(fn node ->
        case node do
          %Node{} -> node.id
          id -> id
        end
      end)

    from net in query,
      left_join: nn in NetworkNode, as: :nn, on: nn.network_slug == net.slug,
      left_join: node in Node, as: :node, on: node.id == nn.node_id,
      where: node.id in ^ids,
      distinct: true
  end

  def has_nodes_exact(query, nodes) when is_list(nodes) do
    ids =
      nodes
      |> Enum.map(fn node ->
        case node do
          %Node{} -> node.id
          id -> id
        end
      end)

    from net in query,
      left_join: nn in NetworkNode, as: :nn, on: nn.network_slug == net.slug,
      left_join: node in Node, as: :node, on: node.id == nn.node_id,
      group_by: net.slug,
      having: fragment("array_agg(?) @> ?", node.id, ^ids)
  end

  def has_sensor(query, %Sensor{path: path}),
    do: has_sensor(query, path)

  def has_sensor(query, path) when is_binary(path),
    do: has_sensors(query, [path])

  def has_sensors(query, sensors) when is_list(sensors) do
    paths =
      sensors
      |> Enum.map(fn sensor ->
        case sensor do
          %Sensor{} -> sensor.path
          path -> path
        end
      end)

    from net in query,
      left_join: ns in NetworkSensor, as: :ns, on: ns.network_slug == net.slug,
      left_join: sensor in Sensor, as: :sensor, on: sensor.path == ns.sensor_path,
      where: sensor.path in ^paths,
      distinct: true
  end

  def has_sensors_exact(query, sensors) when is_list(sensors) do
    paths =
      sensors
      |> Enum.map(fn sensor ->
        case sensor do
          %Sensor{} -> sensor.path
          path -> path
        end
      end)

    from net in query,
      left_join: ns in NetworkSensor, as: :ns, on: ns.network_slug == net.slug,
      left_join: sensor in Sensor, as: :sensor, on: sensor.path == ns.sensor_path,
      group_by: net.slug,
      having: fragment("array_agg(?) @> ?", sensor.path, ^paths)
  end

  def bbox_contains(query, geom),
    do: from net in query,
      where: st_contains(net.bbox, ^geom)

  def bbox_intersects(query, geom),
    do: from net in query,
      where: st_intersects(net.bbox, ^geom)

  defdelegate order(query, args), to: Aot.QueryUtils
  defdelegate paginate(query, args), to: Aot.QueryUtils

  # OTHER ACTION HELPERS

  def handle_opts(query, opts \\ []) do
    [
      include_nodes: false,
      include_sensors: false,
      has_node: :empty,
      has_nodes: :empty,
      has_nodes_exact: :empty,
      has_sensor: :empty,
      has_sensors: :empty,
      has_sensors_exact: :empty,
      bbox_contains: :empty,
      bbox_intersects: :empty,
      order: :empty,
      paginate: :empty
    ]
    |> Keyword.merge(opts)
    |> apply_opts(query, NetworkQueries)
  end

  def compute_bbox(%Network{slug: slug}), do: compute_bbox(slug)
  def compute_bbox(slug),
    do: from node in Node,
      left_join: nn in NetworkNode, as: :nn, on: node.id == nn.node_id,
      where: nn.network_slug == ^slug,
      select: st_envelope(st_union(node.location))

  def compute_hull(%Network{slug: slug}), do: compute_hull(slug)
  def compute_hull(slug),
    do: from node in Node,
      left_join: nn in NetworkNode, as: :nn, on: node.id == nn.node_id,
      where: nn.network_slug == ^slug,
      select: st_convex_hull(st_union(node.location))
end
