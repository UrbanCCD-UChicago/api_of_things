defmodule Aot.RawObservationQueries do
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
    RawObservation,
    RawObservationQueries,
    Sensor
  }

  # BASE QUERIES

  @spec list() :: Ecto.Queryable.t()
  def list,
    do: from obs in RawObservation

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

  # raw value comparisons

  @spec raw(Ecto.Queryable.t(), {:eq | :ge | :gt | :le | :lt, number()}) :: Ecto.Queryable.t()
  def raw(query, {:lt, value}),
    do: from obs in query, where: obs.raw < ^value

  def raw(query, {:le, value}),
    do: from obs in query, where: obs.raw <= ^value

  def raw(query, {:eq, value}),
    do: from obs in query, where: obs.raw == ^value

  def raw(query, {:ge, value}),
    do: from obs in query, where: obs.raw >= ^value

  def raw(query, {:gt, value}),
    do: from obs in query, where: obs.raw > ^value

  # hrf value comparisons

  @spec hrf(Ecto.Queryable.t(), {:eq | :ge | :gt | :le | :lt, number()}) :: Ecto.Queryable.t()
  def hrf(query, {:lt, value}),
    do: from obs in query, where: obs.hrf < ^value

  def hrf(query, {:le, value}),
    do: from obs in query, where: obs.hrf <= ^value

  def hrf(query, {:eq, value}),
    do: from obs in query, where: obs.hrf == ^value

  def hrf(query, {:ge, value}),
    do: from obs in query, where: obs.hrf >= ^value

  def hrf(query, {:gt, value}),
    do: from obs in query, where: obs.hrf > ^value

  # combined value aggregates

  @spec compute_aggs(Ecto.Queryable.t(), :first | :last | {:avg | :count | :max | :min | :stddev | :sum | :variance, atom()} | {:percentile, float(), atom()}) :: Ecto.Queryable.t()
  def compute_aggs(query, :first),
    do: from obs in query,
      select: %{
        raw_first: fragment("first(raw, timestamp)"),
        hrf_first: fragment("first(hrf, timestamp)")
      }

  def compute_aggs(query, :last),
    do: from obs in query,
      select: %{
        raw_last: fragment("last(raw, timestamp)"),
        hrf_last: fragment("last(hrf, timestamp)"),
      }

  def compute_aggs(query, {:count, grouper}),
    do: from obs in query,
    group_by: field(obs, ^grouper),
    select: %{
      group: field(obs, ^grouper),
      raw_count: fragment("count(raw)"),
      hrf_count: fragment("count(hrf)")
    }

  def compute_aggs(query, {:min, grouper}),
    do: from obs in query,
    group_by: field(obs, ^grouper),
    select: %{
      group: field(obs, ^grouper),
      raw_min: fragment("min(raw)"),
      hrf_min: fragment("min(hrf)")
    }

  def compute_aggs(query, {:max, grouper}),
    do: from obs in query,
    group_by: field(obs, ^grouper),
    select: %{
      group: field(obs, ^grouper),
      raw_max: fragment("max(raw)"),
      hrf_max: fragment("max(hrf)")
    }

  def compute_aggs(query, {:avg, grouper}),
    do: from obs in query,
    group_by: field(obs, ^grouper),
    select: %{
      group: field(obs, ^grouper),
      raw_avg: fragment("avg(raw)"),
      hrf_avg: fragment("avg(hrf)")
    }

  def compute_aggs(query, {:sum, grouper}),
    do: from obs in query,
    group_by: field(obs, ^grouper),
    select: %{
      group: field(obs, ^grouper),
      raw_sum: fragment("sum(raw)"),
      hrf_sum: fragment("sum(hrf)")
    }

  def compute_aggs(query, {:stddev, grouper}),
    do: from obs in query,
    group_by: field(obs, ^grouper),
    select: %{
      group: field(obs, ^grouper),
      raw_stddev: fragment("stddev_samp(raw)"),
      hrf_stddev: fragment("stddev_samp(hrf)")
    }

  def compute_aggs(query, {:variance, grouper}),
    do: from obs in query,
    group_by: field(obs, ^grouper),
    select: %{
      group: field(obs, ^grouper),
      raw_variance: fragment("var_samp(raw)"),
      hrf_variance: fragment("var_samp(hrf)")
    }

  def compute_aggs(query, {:percentile, perc, grouper}),
    do: from obs in query,
    group_by: field(obs, ^grouper),
    select: %{
      group: field(obs, ^grouper),
      raw_value: fragment("percentile_cont(?::float) within group (order by raw)", type(^perc, :float)),
      hrf_value: fragment("percentile_cont(?::float) within group (order by hrf)", type(^perc, :float))
    }

  @spec as_histograms(Ecto.Queryable.t(), {number(), number(), number(), number(), integer(), atom()}) :: Ecto.Queryable.t()
  def as_histograms(query, {raw_min, raw_max, hrf_min, hrf_max, count, grouper}),
    do: from obs in query,
      group_by: field(obs, ^grouper),
      select: %{
        group: field(obs, ^grouper),
        raw_histogram: fragment("histogram(raw, ?::float, ?::float, ?::integer)", type(^raw_min, :float), type(^raw_max, :float), type(^count, :integer)),
        hrf_histogram: fragment("histogram(hrf, ?::float, ?::float, ?::integer)", type(^hrf_min, :float), type(^hrf_max, :float), type(^count, :integer))
      }

  @spec as_time_buckets(Ecto.Queryable.t(), {:avg | :count | :max | :min | :stddev | :sum | :variance, binary()} | {:percentile, float(), binary()}) :: Ecto.Queryable.t()
  def as_time_buckets(query, {:count, interval}),
    do: from obs in query,
      group_by: fragment("bucket"),
      order_by: fragment("bucket ASC"),
      select: %{
        bucket: fragment("time_bucket(?::interval, timestamp) as bucket", type(^interval, :string)),
        raw_count: fragment("count(raw)"),
        hrf_count: fragment("count(hrf)"),
      }

  def as_time_buckets(query, {:min, interval}),
    do: from obs in query,
      group_by: fragment("bucket"),
      order_by: fragment("bucket ASC"),
      select: %{
        bucket: fragment("time_bucket(?::interval, timestamp) as bucket", type(^interval, :string)),
        raw_min: fragment("min(raw)"),
        hrf_min: fragment("min(hrf)")
      }

  def as_time_buckets(query, {:max, interval}),
    do: from obs in query,
      group_by: fragment("bucket"),
      order_by: fragment("bucket ASC"),
      select: %{
        bucket: fragment("time_bucket(?::interval, timestamp) as bucket", type(^interval, :string)),
        raw_max: fragment("max(raw)"),
        hrf_max: fragment("max(hrf)")
      }

  def as_time_buckets(query, {:avg, interval}),
    do: from obs in query,
      group_by: fragment("bucket"),
      order_by: fragment("bucket ASC"),
      select: %{
        bucket: fragment("time_bucket(?::interval, timestamp) as bucket", type(^interval, :string)),
        raw_avg: fragment("avg(raw)"),
        hrf_avg: fragment("avg(hrf)")
      }

  def as_time_buckets(query, {:sum, interval}),
    do: from obs in query,
      group_by: fragment("bucket"),
      order_by: fragment("bucket ASC"),
      select: %{
        bucket: fragment("time_bucket(?::interval, timestamp) as bucket", type(^interval, :string)),
        raw_sum: fragment("sum(raw)"),
        hrf_sum: fragment("sum(hrf)")
      }

  def as_time_buckets(query, {:stddev, interval}),
    do: from obs in query,
      group_by: fragment("bucket"),
      order_by: fragment("bucket ASC"),
      select: %{
        bucket: fragment("time_bucket(?::interval, timestamp) as bucket", type(^interval, :string)),
        raw_stddev: fragment("stddev_samp(raw)"),
        hrf_stddev: fragment("stddev_samp(hrf)")
      }

  def as_time_buckets(query, {:variance, interval}),
    do: from obs in query,
      group_by: fragment("bucket"),
      order_by: fragment("bucket ASC"),
      select: %{
        bucket: fragment("time_bucket(?::interval, timestamp) as bucket", type(^interval, :string)),
        raw_variance: fragment("var_samp(raw)"),
        hrf_variance: fragment("var_samp(hrf)")
      }

  def as_time_buckets(query, {:percentile, perc, interval}),
    do: from obs in query,
      group_by: fragment("bucket"),
      order_by: fragment("bucket ASC"),
      select: %{
        bucket: fragment("time_bucket(?::interval, timestamp) as bucket", type(^interval, :string)),
        raw_value: fragment("percentile_cont(?::float) within group (order by raw)", type(^perc, :float)),
        hrf_value: fragment("percentile_cont(?::float) within group (order by hrf)", type(^perc, :float))
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
        raw: :empty,
        hrf: :empty,
        compute_aggs: :empty,
        as_histograms: :empty,
        as_time_buckets: :empty,
        order: :empty,
        paginate: :empty
      ]
      |> Keyword.merge(opts)

    query
    |> boolean_compose(opts[:embed_node], RawObservationQueries, :embed_node)
    |> boolean_compose(opts[:embed_sensor], RawObservationQueries, :embed_sensor)
    |> filter_compose(opts[:of_network], RawObservationQueries, :of_network)
    |> filter_compose(opts[:of_networks], RawObservationQueries, :of_networks)
    |> filter_compose(opts[:by_sensor], RawObservationQueries, :by_sensor)
    |> filter_compose(opts[:by_sensors], RawObservationQueries, :by_sensors)
    |> filter_compose(opts[:located_within], RawObservationQueries, :located_within)
    |> filter_compose(opts[:located_within_distance], RawObservationQueries, :located_within_distance)
    |> filter_compose(opts[:timestamp], RawObservationQueries, :timestamp)
    |> filter_compose(opts[:raw], RawObservationQueries, :raw)
    |> filter_compose(opts[:hrf], RawObservationQueries, :hrf)
    |> filter_compose(opts[:compute_aggs], RawObservationQueries, :compute_aggs)
    |> filter_compose(opts[:as_histograms], RawObservationQueries, :as_histograms)
    |> filter_compose(opts[:as_time_buckets], RawObservationQueries, :as_time_buckets)
    |> filter_compose(opts[:order], RawObservationQueries, :order)
    |> filter_compose(opts[:paginate], RawObservationQueries, :paginate)
  end
end
