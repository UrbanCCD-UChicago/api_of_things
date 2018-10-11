defmodule Aot.NodeQueries do
  @moduledoc """
  """

  import Aot.QueryUtils, only: [
    boolean_compose: 4,
    filter_compose: 4
  ]

  import Ecto.Query

  import Geo.PostGIS, only: [
    st_contains: 2,
    st_dwithin_in_meters: 3
  ]

  alias Aot.{
    Network,
    NetworkNode,
    Node,
    NodeQueries,
    NodeSensor,
    Sensor
  }

  # BASE QUERIES

  @spec list() :: Ecto.Queryable.t()
  def list,
    do: from node in Node

  @spec get(Ecto.Queryable.t()) :: Ecto.Queryable.t()
  def get(id),
    do: from node in Node,
      where: node.id == ^id

  # BOOLEAN COMPOSE

  @spec include_networks(Ecto.Queryable.t()) :: Ecto.Queryable.t()
  def include_networks(query),
    do: from node in query,
      preload: [networks: :nodes]

  @spec include_sensors(Ecto.Queryable.t()) :: Ecto.Queryable.t()
  def include_sensors(query),
    do: from node in query,
      preload: [sensors: :nodes]

  @spec assert_alive(Ecto.Queryable.t()) :: Ecto.Queryable.t()
  def assert_alive(query),
    do: from node in query,
      where: is_nil(node.decommissioned_on)

  @spec assert_dead(Ecto.Queryable.t()) :: Ecto.Queryable.t()
  def assert_dead(query),
    do: from node in query,
      where: not is_nil(node.decommissioned_on)


  # FILTER COMPOSE

  @spec within_network(Ecto.Queryable.t(), binary() | Aot.Network.t()) :: Ecto.Queryable.t()
  def within_network(query, %Network{slug: slug}),
    do: within_network(query, slug)

  def within_network(query, slug) when is_binary(slug),
    do: within_networks(query, [slug])

  @spec within_networks(Ecto.Queryable.t(), maybe_improper_list()) :: Ecto.Queryable.t()
  def within_networks(query, networks) when is_list(networks) do
    slugs =
      networks
      |> Enum.map(fn net ->
        case net do
          %Network{} -> net.slug
          slug -> slug
        end
      end)

    from node in query,
      left_join: nn in NetworkNode, as: :nn, on: nn.node_id == node.id,
      left_join: net in Network, as: :net, on: nn.network_slug == net.slug,
      where: net.slug in ^slugs,
      distinct: true
  end

  @spec within_networks_exact(Ecto.Queryable.t(), maybe_improper_list()) :: Ecto.Queryable.t()
  def within_networks_exact(query, networks) when is_list(networks) do
    slugs =
      networks
      |> Enum.map(fn net ->
        case net do
          %Network{} -> net.slug
          slug -> slug
        end
      end)

    from node in query,
      left_join: nn in NetworkNode, as: :nn, on: nn.node_id == node.id,
      left_join: net in Network, as: :net, on: nn.network_slug == net.slug,
      group_by: node.id,
      having: fragment("array_agg(?) @> ?", net.slug, ^slugs)
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

    from node in query,
      left_join: ns in NodeSensor, as: :ns, on: ns.node_id == node.id,
      left_join: sensor in Sensor, as: :sensor, on: ns.sensor_path == sensor.path,
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

    from node in query,
      left_join: ns in NodeSensor, as: :ns, on: ns.node_id == node.id,
      left_join: sensor in Sensor, as: :sensor, on: ns.sensor_path == sensor.path,
      group_by: node.id,
      having: fragment("array_agg(?) @> ?", sensor.path, ^paths)
  end

  @spec located_within_distance(Ecto.Queryable.t(), {number(), Geo.Point.t()}) :: Ecto.Queryable.t()
  def located_within_distance(query, {meters, geom}),
    do: from node in query,
      where: st_dwithin_in_meters(node.location, ^geom, ^meters)

  @spec located_within(Ecto.Queryable.t(), Geo.Polygon.t()) :: Ecto.Queryable.t()
  def located_within(query, geom),
    do: from node in query,
      where: st_contains(^geom, node.location)

  @spec commissioned_on(Ecto.Queryable.t(), {:eq | :ge | :gt | :le | :lt, NaiveDateTime.t()}) :: Ecto.Queryable.t()
  def commissioned_on(query, {:lt, value}), do: from node in query, where: node.commissioned_on < ^value
  def commissioned_on(query, {:le, value}), do: from node in query, where: node.commissioned_on <= ^value
  def commissioned_on(query, {:eq, value}), do: from node in query, where: node.commissioned_on == ^value
  def commissioned_on(query, {:ge, value}), do: from node in query, where: node.commissioned_on >= ^value
  def commissioned_on(query, {:gt, value}), do: from node in query, where: node.commissioned_on > ^value

  @spec decommissioned_on(Ecto.Queryable.t(), {:eq | :ge | :gt | :le | :lt, NaiveDateTime.t()}) :: Ecto.Queryable.t()
  def decommissioned_on(query, {:lt, value}), do: from node in query, where: node.decommissioned_on < ^value
  def decommissioned_on(query, {:le, value}), do: from node in query, where: node.decommissioned_on <= ^value
  def decommissioned_on(query, {:eq, value}), do: from node in query, where: node.decommissioned_on == ^value
  def decommissioned_on(query, {:ge, value}), do: from node in query, where: node.decommissioned_on >= ^value
  def decommissioned_on(query, {:gt, value}), do: from node in query, where: node.decommissioned_on > ^value

  defdelegate order(query, args), to: Aot.QueryUtils
  defdelegate paginate(query, args), to: Aot.QueryUtils

  # OTHER ACTION HELPERS

  @spec handle_opts(Ecto.Queryable.t(), keyword()) :: Ecto.Queryable.t()
  def handle_opts(query, opts \\ []) do
    opts =
      [
        include_networks: false,
        include_sensors: false,
        assert_alive: false,
        assert_dead: false,
        within_network: :empty,
        within_networks: :empty,
        within_networks_exact: :empty,
        has_sensor: :empty,
        has_sensors: :empty,
        has_sensors_exact: :empty,
        located_within_distance: :empty,
        located_within: :empty,
        commissioned_on: :empty,
        decommissioned_on: :empty,
        order: :empty,
        paginate: :empty
      ]
      |> Keyword.merge(opts)

    query
    |> boolean_compose(opts[:include_networks], NodeQueries, :include_networks)
    |> boolean_compose(opts[:include_sensors], NodeQueries, :include_sensors)
    |> boolean_compose(opts[:assert_alive], NodeQueries, :assert_alive)
    |> boolean_compose(opts[:assert_dead], NodeQueries, :assert_dead)
    |> filter_compose(opts[:within_network], NodeQueries, :within_network)
    |> filter_compose(opts[:within_networks], NodeQueries, :within_networks)
    |> filter_compose(opts[:within_networks_exact], NodeQueries, :within_networks_exact)
    |> filter_compose(opts[:has_sensor], NodeQueries, :has_sensor)
    |> filter_compose(opts[:has_sensors], NodeQueries, :has_sensors)
    |> filter_compose(opts[:has_sensors_exact], NodeQueries, :has_sensors_exact)
    |> filter_compose(opts[:located_within], NodeQueries, :located_within)
    |> filter_compose(opts[:located_within_distance], NodeQueries, :located_within_distance)
    |> filter_compose(opts[:commissioned_on], NodeQueries, :commissioned_on)
    |> filter_compose(opts[:decommissioned_on], NodeQueries, :decommissioned_on)
    |> filter_compose(opts[:order], NodeQueries, :order)
    |> filter_compose(opts[:paginate], NodeQueries, :paginate)
  end
end
