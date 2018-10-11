defmodule Aot.ObservationQueries do
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
    Observation,
    ObservationQueries,
    Sensor
  }

  # BASE QUERIES

  @spec list() :: Ecto.Queryable.t()
  def list,
    do: from obs in Observation

  # BOOLEAN COMPOSE

  @spec embed_node(Ecto.Queryable.t()) :: Ecto.Queryable.t()
  def embed_node(query),
    do: from obs in query,
      preload: [node: :observations]

  @spec embed_sensor(Ecto.Queryable.t()) :: Ecto.Queryable.t()
  def embed_sensor(query),
    do: from obs in query,
      preload: [sensor: :observations]

  # FILTER COMPOSE

  @spec of_network(Ecto.Queryable.t(), binary() | Aot.Network.t()) :: Ecto.Queryable.t()
  def of_network(query, %Network{slug: slug}),
    do: of_network(query, slug)

  def of_network(query, slug) when is_binary(slug),
    do: of_networks(query, [slug])

  @spec of_networks(Ecto.Queryable.t(), any()) :: Ecto.Queryable.t()
  def of_networks(query, networks) do
    slugs =
      networks
      |> Enum.map(fn net ->
        case net do
          %Network{} -> net.slug
          slug -> slug
        end
      end)

    from obs in query,
      left_join: nn in NetworkNode, as: :nn, on: nn.node_id == obs.node_id,
      where: nn.network_slug in ^slugs
  end

  @spec from_node(Ecto.Queryable.t(), binary() | Aot.Node.t()) :: Ecto.Queryable.t()
  def from_node(query, %Node{id: id}),
    do: from_node(query, id)

  def from_node(query, id) when is_binary(id),
    do: from_nodes(query, [id])

  @spec from_nodes(Ecto.Queryable.t(), maybe_improper_list()) :: Ecto.Queryable.t()
  def from_nodes(query, nodes) when is_list(nodes) do
    ids =
      nodes
      |> Enum.map(fn node ->
        case node do
          %Node{} -> node.id
          id -> id
        end
      end)

    from obs in query,
      where: obs.node_id in ^ids
  end

  @spec by_sensor(Ecto.Queryable.t(), binary() | Aot.Sensor.t()) :: Ecto.Queryable.t()
  def by_sensor(query, %Sensor{path: path}),
    do: by_sensor(query, path)

  def by_sensor(query, path) when is_binary(path),
    do: by_sensors(query, [path])

  @spec by_sensors(Ecto.Queryable.t(), maybe_improper_list()) :: Ecto.Queryable.t()
  def by_sensors(query, sensors) when is_list(sensors) do
    paths =
      sensors
      |> Enum.map(fn sensor ->
        case sensor do
          %Sensor{} -> sensor.path
          path -> path
        end
      end)

    from obs in query,
      where: obs.sensor_path in ^paths
  end

  @spec located_within_distance(Ecto.Queryable.t(), {number(), Geo.Point.t()}) :: Ecto.Queryable.t()
  def located_within_distance(query, {meters, geom}),
    do: from obs in query,
      left_join: node in Node, as: :node, on: node.id == obs.node_id,
      where: st_dwithin_in_meters(node.location, ^geom, ^meters)

  @spec located_within(Ecto.Queryable.t(), Geo.Polygon.t()) :: Ecto.Queryable.t()
  def located_within(query, geom),
    do: from obs in query,
      left_join: node in Node, as: :node, on: node.id == obs.node_id,
      where: st_contains(^geom, node.location)

  @spec timestamp(Ecto.Queryable.t(), {:eq | :ge | :gt | :le | :lt, NaiveDateTime.t()}) :: Ecto.Queryable.t()
  def timestamp(query, {:lt, value}),
    do: from obs in query, where: obs.timestamp < ^value

  def timestamp(query, {:le, value}),
    do: from obs in query, where: obs.timestamp <= ^value

  def timestamp(query, {:eq, value}),
    do: from obs in query, where: obs.timestamp == ^value

  def timestamp(query, {:ge, value}),
    do: from obs in query, where: obs.timestamp >= ^value

  def timestamp(query, {:gt, value}),
    do: from obs in query, where: obs.timestamp > ^value

  # value comparisons

  @spec value(Ecto.Queryable.t(), :first | :last | {:avg | :count | :eq | :ge | :gt | :le | :lt, number()} | {:max | :min | :stddev | :sum | :variance, binary()} | {:percentile, float(), binary()}) :: Ecto.Queryable.t()
  def value(query, {:lt, value}),
    do: from obs in query, where: obs.value < ^value

  def value(query, {:le, value}),
    do: from obs in query, where: obs.value <= ^value

  def value(query, {:eq, value}),
    do: from obs in query, where: obs.value == ^value

  def value(query, {:ge, value}),
    do: from obs in query, where: obs.value >= ^value

  def value(query, {:gt, value}),
    do: from obs in query, where: obs.value > ^value

  # value aggregates

  def value(query, :first),
    do: from obs in query,
      select: %{
        first: fragment("first(value, timestamp)")
      }

  def value(query, :last),
    do: from obs in query,
      select: %{
        last: fragment("last(value, timestamp)")
      }

  def value(query, {:count, grouper}),
    do: from obs in query,
    group_by: field(obs, ^grouper),
    select: %{
      group: field(obs, ^grouper),
      count: fragment("count(value)")
    }

  def value(query, {:min, grouper}),
    do: from obs in query,
    group_by: field(obs, ^grouper),
    select: %{
      group: field(obs, ^grouper),
      min: fragment("min(value)")
    }

  def value(query, {:max, grouper}),
    do: from obs in query,
    group_by: field(obs, ^grouper),
    select: %{
      group: field(obs, ^grouper),
      max: fragment("max(value)")
    }

  def value(query, {:avg, grouper}),
    do: from obs in query,
    group_by: field(obs, ^grouper),
    select: %{
      group: field(obs, ^grouper),
      avg: fragment("avg(value)")
    }

  def value(query, {:sum, grouper}),
    do: from obs in query,
    group_by: field(obs, ^grouper),
    select: %{
      group: field(obs, ^grouper),
      sum: fragment("sum(value)")
    }

  def value(query, {:stddev, grouper}),
    do: from obs in query,
    group_by: field(obs, ^grouper),
    select: %{
      group: field(obs, ^grouper),
      stddev: fragment("stddev_samp(value)")
    }

  def value(query, {:variance, grouper}),
    do: from obs in query,
    group_by: field(obs, ^grouper),
    select: %{
      group: field(obs, ^grouper),
      variance: fragment("var_samp(value)")
    }

  def value(query, {:percentile, perc, grouper}),
    do: from obs in query,
    group_by: field(obs, ^grouper),
    select: %{
      group: field(obs, ^grouper),
      value: fragment("percentile_cont(?::float) within group (order by value)", type(^perc, :float))
    }

  @spec as_histogram(Ecto.Queryable.t(), {float(), float(), integer(), atom()}) :: Ecto.Queryable.t()
  def as_histogram(query, {min, max, count, grouper}),
    do: from obs in query,
      group_by: field(obs, ^grouper),
      select: %{
        group: field(obs, ^grouper),
        histogram: fragment("histogram(value, ?::float, ?::float, ?::integer)", type(^min, :float), type(^max, :float), type(^count, :integer))
      }

  @spec as_time_buckets(Ecto.Queryable.t(), {:avg | :count | :max | :min | :stddev | :sum | :variance, binary()} | {:percentile, float(), binary()}) :: Ecto.Queryable.t()
  def as_time_buckets(query, {:count, interval}),
    do: from obs in query,
      group_by: fragment("bucket"),
      order_by: fragment("bucket ASC"),
      select: %{
        bucket: fragment("time_bucket(?::interval, timestamp) as bucket", type(^interval, :string)),
        count: fragment("count(value)")
      }

  def as_time_buckets(query, {:min, interval}),
    do: from obs in query,
      group_by: fragment("bucket"),
      order_by: fragment("bucket ASC"),
      select: %{
        bucket: fragment("time_bucket(?::interval, timestamp) as bucket", type(^interval, :string)),
        min: fragment("min(value)")
      }

  def as_time_buckets(query, {:max, interval}),
    do: from obs in query,
      group_by: fragment("bucket"),
      order_by: fragment("bucket ASC"),
      select: %{
        bucket: fragment("time_bucket(?::interval, timestamp) as bucket", type(^interval, :string)),
        max: fragment("max(value)")
      }

  def as_time_buckets(query, {:avg, interval}),
    do: from obs in query,
      group_by: fragment("bucket"),
      order_by: fragment("bucket ASC"),
      select: %{
        bucket: fragment("time_bucket(?::interval, timestamp) as bucket", type(^interval, :string)),
        avg: fragment("avg(value)")
      }

  def as_time_buckets(query, {:sum, interval}),
    do: from obs in query,
      group_by: fragment("bucket"),
      order_by: fragment("bucket ASC"),
      select: %{
        bucket: fragment("time_bucket(?::interval, timestamp) as bucket", type(^interval, :string)),
        sum: fragment("sum(value)")
      }

  def as_time_buckets(query, {:stddev, interval}),
    do: from obs in query,
      group_by: fragment("bucket"),
      order_by: fragment("bucket ASC"),
      select: %{
        bucket: fragment("time_bucket(?::interval, timestamp) as bucket", type(^interval, :string)),
        stddev: fragment("stddev_samp(value)")
      }

  def as_time_buckets(query, {:variance, interval}),
    do: from obs in query,
      group_by: fragment("bucket"),
      order_by: fragment("bucket ASC"),
      select: %{
        bucket: fragment("time_bucket(?::interval, timestamp) as bucket", type(^interval, :string)),
        variance: fragment("var_samp(value)")
      }

  def as_time_buckets(query, {:percentile, perc, interval}),
    do: from obs in query,
      group_by: fragment("bucket"),
      order_by: fragment("bucket ASC"),
      select: %{
        bucket: fragment("time_bucket(?::interval, timestamp) as bucket", type(^interval, :string)),
        value: fragment("percentile_cont(?::float) within group (order by value)", type(^perc, :float))
      }

  defdelegate order(query, args), to: Aot.QueryUtils
  defdelegate paginate(query, args), to: Aot.QueryUtils

  # OTHER ACTION HELPERS

  @spec handle_opts(Ecto.Queryable.t(), keyword()) :: Ecto.Queryable.t()
  def handle_opts(query, opts \\ []) do
    opts =
      [
        embed_node: false,
        embed_sensor: false,
        of_network: :empty,
        of_networks: :empty,
        from_node: :empty,
        from_nodes: :empty,
        by_sensor: :empty,
        by_sensors: :empty,
        located_within_distance: :empty,
        located_within: :empty,
        timestamp: :empty,
        value: :empty,
        as_histogram: :empty,
        as_time_buckets: :empty,
        order: :empty,
        paginate: :empty
      ]
      |> Keyword.merge(opts)

    query
    |> boolean_compose(opts[:embed_node], ObservationQueries, :embed_node)
    |> boolean_compose(opts[:embed_sensor], ObservationQueries, :embed_sensor)
    |> filter_compose(opts[:of_network], ObservationQueries, :of_network)
    |> filter_compose(opts[:of_networks], ObservationQueries, :of_networks)
    |> filter_compose(opts[:from_node], ObservationQueries, :from_node)
    |> filter_compose(opts[:from_nodes], ObservationQueries, :from_nodes)
    |> filter_compose(opts[:by_sensor], ObservationQueries, :by_sensor)
    |> filter_compose(opts[:by_sensors], ObservationQueries, :by_sensors)
    |> filter_compose(opts[:located_within_distance], ObservationQueries, :located_within_distance)
    |> filter_compose(opts[:located_within], ObservationQueries, :located_within)
    |> filter_compose(opts[:timestamp], ObservationQueries, :timestamp)
    |> filter_compose(opts[:value], ObservationQueries, :value)
    |> filter_compose(opts[:as_histogram], ObservationQueries, :as_histogram)
    |> filter_compose(opts[:as_time_buckets], ObservationQueries, :as_time_buckets)
    |> filter_compose(opts[:order], ObservationQueries, :order)
    |> filter_compose(opts[:paginate], ObservationQueries, :paginate)
  end
end
