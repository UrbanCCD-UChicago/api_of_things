defmodule Aot.ProjectQueries do
  @moduledoc """
  """

  import Aot.QueryUtils, only: [
    boolean_compose: 4,
    filter_compose: 4
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
    Project,
    ProjectNode,
    ProjectQueries,
    ProjectSensor,
    Node,
    Sensor
  }

  # BASE QUERIES

  @spec list() :: Ecto.Queryable.t()
  def list,
    do: from net in Project

  @spec get(Ecto.Queryable.t()) :: Ecto.Queryable.t()
  def get(slug),
    do: from net in Project,
      where: net.slug == ^slug

  # BOOLEAN COMPOSE

  @spec include_nodes(Ecto.Queryable.t()) :: Ecto.Queryable.t()
  def include_nodes(query),
    do: from net in query,
      preload: [nodes: :projects]

  @spec include_sensors(Ecto.Queryable.t()) :: Ecto.Queryable.t()
  def include_sensors(query),
    do: from net in query,
      preload: [sensors: :projects]

  # FILTER COMPOSE

  @spec has_node(Ecto.Queryable.t(), binary() | Aot.Node.t()) :: Ecto.Queryable.t()
  def has_node(query, %Node{id: id}),
    do: has_node(query, id)

  def has_node(query, id) when is_binary(id),
    do: has_nodes(query, [id])

  @spec has_nodes(Ecto.Queryable.t(), maybe_improper_list()) :: Ecto.Queryable.t()
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
      left_join: nn in ProjectNode, as: :nn, on: nn.project_slug == net.slug,
      left_join: node in Node, as: :node, on: node.id == nn.node_id,
      where: node.id in ^ids,
      distinct: true
  end

  @spec has_nodes_exact(Ecto.Queryable.t(), maybe_improper_list()) :: Ecto.Queryable.t()
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
      left_join: nn in ProjectNode, as: :nn, on: nn.project_slug == net.slug,
      left_join: node in Node, as: :node, on: node.id == nn.node_id,
      group_by: net.slug,
      having: fragment("array_agg(?) @> ?", node.id, ^ids)
  end

  @spec has_sensor(Ecto.Queryable.t(), binary() | Aot.Sensor.t()) :: Ecto.Queryable.t()
  def has_sensor(query, %Sensor{path: path}),
    do: has_sensor(query, path)

  def has_sensor(query, path) when is_binary(path),
    do: has_sensors(query, [path])

  @spec has_sensors(Ecto.Queryable.t(), maybe_improper_list()) :: Ecto.Queryable.t()
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
      left_join: ns in ProjectSensor, as: :ns, on: ns.project_slug == net.slug,
      left_join: sensor in Sensor, as: :sensor, on: sensor.path == ns.sensor_path,
      where: sensor.path in ^paths,
      distinct: true
  end

  @spec has_sensors_exact(Ecto.Queryable.t(), maybe_improper_list()) :: Ecto.Queryable.t()
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
      left_join: ns in ProjectSensor, as: :ns, on: ns.project_slug == net.slug,
      left_join: sensor in Sensor, as: :sensor, on: sensor.path == ns.sensor_path,
      group_by: net.slug,
      having: fragment("array_agg(?) @> ?", sensor.path, ^paths)
  end

  @spec bbox_contains(Ecto.Queryable.t(), Geo.Point.t()) :: Ecto.Queryable.t()
  def bbox_contains(query, geom),
    do: from net in query,
      where: st_contains(net.bbox, ^geom)

  @spec bbox_intersects(Ecto.Queryable.t(), Geo.Polygon.t()) :: Ecto.Queryable.t()
  def bbox_intersects(query, geom),
    do: from net in query,
      where: st_intersects(net.bbox, ^geom)

  defdelegate order(query, args), to: Aot.QueryUtils
  defdelegate paginate(query, args), to: Aot.QueryUtils

  # OTHER ACTION HELPERS

  @spec handle_opts(Ecto.Queryable.t(), keyword()) :: Ecto.Queryable.t()
  def handle_opts(query, opts \\ []) do
    opts =
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

    query
    |> boolean_compose(opts[:include_nodes], ProjectQueries, :include_nodes)
    |> boolean_compose(opts[:include_sensors], ProjectQueries, :include_sensors)
    |> filter_compose(opts[:has_node], ProjectQueries, :has_node)
    |> filter_compose(opts[:has_nodes], ProjectQueries, :has_nodes)
    |> filter_compose(opts[:has_nodes_exact], ProjectQueries, :has_nodes_exact)
    |> filter_compose(opts[:has_sensor], ProjectQueries, :has_sensor)
    |> filter_compose(opts[:has_sensors], ProjectQueries, :has_sensors)
    |> filter_compose(opts[:has_sensors_exact], ProjectQueries, :has_sensors_exact)
    |> filter_compose(opts[:bbox_contains], ProjectQueries, :bbox_contains)
    |> filter_compose(opts[:bbox_intersects], ProjectQueries, :bbox_intersects)
    |> filter_compose(opts[:order], ProjectQueries, :order)
    |> filter_compose(opts[:paginate], ProjectQueries, :paginate)
  end

  def compute_bbox(%Project{slug: slug}), do: compute_bbox(slug)
  def compute_bbox(slug),
    do: from node in Node,
      left_join: nn in ProjectNode, as: :nn, on: node.id == nn.node_id,
      where: nn.project_slug == ^slug,
      select: st_envelope(st_union(node.location))

  def compute_hull(%Project{slug: slug}), do: compute_hull(slug)
  def compute_hull(slug),
    do: from node in Node,
      left_join: nn in ProjectNode, as: :nn, on: node.id == nn.node_id,
      where: nn.project_slug == ^slug,
      select: st_convex_hull(st_union(node.location))
end
