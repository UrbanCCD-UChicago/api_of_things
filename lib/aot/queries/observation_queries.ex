defmodule Aot.ObservationQueries do
  @moduledoc """
  Stored base queries and functions to compose queries for Nodes.
  """

  import Aot.QueryUtils, only: [
    apply_opts: 3,
    field_op: 4,
    typed_field_op: 5
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

  @spec list() :: Ecto.Queryable.t()
  def list, do: Observation

  @spec with_node(Ecto.Queryable.t()) :: Ecto.Queryable.t()
  def with_node(query), do: preload(query, :node)

  @spec with_sensor(Ecto.Queryable.t()) :: Ecto.Queryable.t()
  def with_sensor(query), do: preload(query, :sensor)

  @spec with_networks(Ecto.Queryable.t()) :: Ecto.Queryable.t()
  def with_networks(query), do: preload(query, node: :networks)

  @spec assert_hrf(Ecto.Queryable.t()) :: Ecto.Queryable.t()
  def assert_hrf(query), do: where(query, [o], o.raw? == false)

  @spec assert_raw(Ecto.Queryable.t()) :: Ecto.Queryable.t()
  def assert_raw(query), do: where(query, [o], o.raw? == true)

  @spec for_network(Ecto.Queryable.t(), Network.t() | integer() | String.t()) :: Ecto.Queryable.t()
  def for_network(query, %Network{id: id}), do: for_network(query, id)
  def for_network(query, id), do: for_networks(query, [id])

  @spec for_networks(Ecto.Queryable.t(), list(Network.t() | integer() | String.t())) :: Ecto.Queryable.t()
  def for_networks(query, networks) do
    network_ids =
      networks
      |> Enum.map(fn network ->
        case network do
          %Network{id: id} -> id
          id -> id
        end
      end)
      |> Enum.map(& "#{&1}")

    from o in query,
      left_join: nn in NetworkNode, on: o.node_id == nn.node_id,
      left_join: n in Network, on: n.id == nn.network_id,
      where: fragment("?::text = ANY(?)", n.id, type(^network_ids, {:array, :string})) or n.slug in type(^network_ids, {:array, :string}),
      distinct: true
  end

  @spec for_node(Ecto.Queryable.t(), Node.t() | String.t()) :: Ecto.Query.t()
  def for_node(query, %Node{id: id}), do: for_node(query, id)
  def for_node(query, id), do: for_nodes(query, [id])

  @spec for_nodes(Ecto.Queryable.t(), list(Node.t() | String.t())) :: Ecto.Queryable.t()
  def for_nodes(query, nodes) do
    node_ids =
      nodes
      |> Enum.map(fn node ->
        case node do
          %Node{id: id} -> id
          id -> id
        end
      end)

    from o in query,
      left_join: n in Node, on: o.node_id == n.id,
      where: n.id in type(^node_ids, {:array, :string}) or n.vsn in type(^node_ids, {:array, :string})
  end

  @spec for_sensor(Ecto.Queryable.t(), Sensor.t() | integer() | String.t()) :: Ecto.Queryable.t()
  def for_sensor(query, %Sensor{id: id}), do: for_sensor(query, id)
  def for_sensor(query, id), do: for_sensors(query, [id])

  @spec for_sensors(Ecto.Queryable.t(), list(Sensor.t() | integer() | String.t())) :: Ecto.Queryable.t()
  def for_sensors(query, sensors) do
    sensor_ids =
      sensors
      |> Enum.map(fn sensor ->
        case sensor do
          %Sensor{id: id} -> id
          id -> id
        end
      end)
      |> Enum.map(& "#{&1}")

    from o in query,
      left_join: s in Sensor, on: o.sensor_id == s.id,
      where: fragment("?::text = ANY(?)", s.id, type(^sensor_ids, {:array, :string})) or s.path in type(^sensor_ids, {:array, :string})
  end

  @spec timestamp_op(Ecto.Queryable.t(), {:between | :eq | :ge | :gt | :in | :le | :lt, NaiveDateTime.t()}) :: Ecto.Queryable.t()
  def timestamp_op(query, {op, value}), do: typed_field_op(query, :timestamp, op, value, :naive_datetime)

  @spec value_op(Ecto.Queryable.t(), {:between | :eq | :ge | :gt | :in | :le | :lt, NaiveDateTime.t()}) :: Ecto.Queryable.t()
  def value_op(query, {op, value}), do: field_op(query, :value, op, value)

  @spec located_within(Ecto.Queryable.t(), Geo.PostGIS.Geometry.t()) :: Ecto.Queryable.t()
  def located_within(query, geom) do
    from o in query,
      left_join: n in Node, on: o.node_id == n.id,
      where: st_contains(^geom, n.location)
  end

  @spec within_distance(Ecto.Queryable.t(), {Geo.PostGIS.Geometry.t(), float()}) :: Ecto.Queryable.t()
  def within_distance(query, {geom, meters}) do
    from o in query,
      left_join: n in Node, on: o.node_id == n.id,
      where: st_dwithin_in_meters(n.location, ^geom, ^meters)
  end

  @spec as_histogram(Ecto.Queryable.t(), {float(), float(), integer(), atom()}) :: Ecto.Queryable.t()
  def as_histogram(query, {min, max, num_buckets, groupby}) do
    query
    |> select([o], [
      field(o, ^groupby),
      fragment("histogram(value, ?, ?, ?)", ^min, ^max, ^num_buckets)
    ])
    |> group_by([o], field(o, ^groupby))
  end

  @spec value_agg(Ecto.Queryable.t(), {:avg | :count | :first | :last | :max | :min | :stddev | :sum | :variance, atom()} | {:percentile, {float(), atom()}}) :: Ecto.Queryable.t()
  def value_agg(query, {:first, _groupby}), do: select(query, [o], fragment("first(value, timestamp)"))

  def value_agg(query, {:last, _groupby}), do: select(query, [o], fragment("last(value, timestamp)"))

  def value_agg(query, {:count, groupby}) do
    query
    |> select([o], [field(o, ^groupby), fragment("count(value)")])
    |> group_by([o], field(o, ^groupby))
  end

  def value_agg(query, {:min, groupby}) do
    query
    |> select([o], [field(o, ^groupby), fragment("min(value)")])
    |> group_by([o], field(o, ^groupby))
  end

  def value_agg(query, {:max, groupby}) do
    query
    |> select([o], [field(o, ^groupby), fragment("max(value)")])
    |> group_by([o], field(o, ^groupby))
  end

  def value_agg(query, {:avg, groupby}) do
    query
    |> select([o], [field(o, ^groupby), fragment("avg(value)")])
    |> group_by([o], field(o, ^groupby))
  end

  def value_agg(query, {:sum, groupby}) do
    query
    |> select([o], [field(o, ^groupby), fragment("sum(value)")])
    |> group_by([o], field(o, ^groupby))
  end

  def value_agg(query, {:stddev, groupby}) do
    query
    |> select([o], [field(o, ^groupby), fragment("stddev_samp(value)")])
    |> group_by([o], field(o, ^groupby))
  end

  def value_agg(query, {:variance, groupby}) do
    query
    |> select([o], [field(o, ^groupby), fragment("var_samp(value)")])
    |> group_by([o], field(o, ^groupby))
  end

  def value_agg(query, {:percentile, {perc, groupby}}) do
    query
    |> select([o], [field(o, ^groupby), fragment("percentile_cont(?) within group (order by value)", ^perc)])
    |> group_by([o], field(o, ^groupby))
  end

  @spec as_time_buckets(Ecto.Queryable.t(), {String.t(), :avg | :count | :max | :min | :stddev | :sum | :variance | {:percentile, float()}}) :: Ecto.Query.t()
  def as_time_buckets(query, {:count, interval}) do
    query
    |> select([
      fragment("time_bucket(?::interval, timestamp) as bucket", type(^interval, :string)),
      fragment("count(value) as count")
    ])
    |> group_by(fragment("bucket"))
    |> order_by(fragment("bucket DESC"))
  end

  def as_time_buckets(query, {:min, interval}) do
    query
    |> select([
      fragment("time_bucket(?::interval, timestamp) as bucket", type(^interval, :string)),
      fragment("min(value) as min")
    ])
    |> group_by(fragment("bucket"))
    |> order_by(fragment("bucket DESC"))
  end

  def as_time_buckets(query, {:max, interval}) do
    query
    |> select([
      fragment("time_bucket(?::interval, timestamp) as bucket", type(^interval, :string)),
      fragment("max(value) as max")
    ])
    |> group_by(fragment("bucket"))
    |> order_by(fragment("bucket DESC"))
  end

  def as_time_buckets(query, {:avg, interval}) do
    query
    |> select([
      fragment("time_bucket(?::interval, timestamp) as bucket", type(^interval, :string)),
      fragment("avg(value) as avg")
    ])
    |> group_by(fragment("bucket"))
    |> order_by(fragment("bucket DESC"))
  end

  def as_time_buckets(query, {:sum, interval}) do
    query
    |> select([
      fragment("time_bucket(?::interval, timestamp) as bucket", type(^interval, :string)),
      fragment("sum(value) as sum")
    ])
    |> group_by(fragment("bucket"))
    |> order_by(fragment("bucket DESC"))
  end

  def as_time_buckets(query, {:stddev, interval}) do
    query
    |> select([
      fragment("time_bucket(?::interval, timestamp) as bucket", type(^interval, :string)),
      fragment("stddev_samp(value) as stddev")
    ])
    |> group_by(fragment("bucket"))
    |> order_by(fragment("bucket DESC"))
  end

  def as_time_buckets(query, {:variance, interval}) do
    query
    |> select([
      fragment("time_bucket(?::interval, timestamp) as bucket", type(^interval, :string)),
      fragment("var_samp(value) as variance")
    ])
    |> group_by(fragment("bucket"))
    |> order_by(fragment("bucket DESC"))
  end

  def as_time_buckets(query, {{:percentile, perc}, interval}) do
    query
    |> select([
      fragment("time_bucket(?::interval, timestamp) as bucket", type(^interval, :string)),
      fragment("percentile_cont(?) within group (order by value) as percentile", ^perc)
    ])
    |> group_by(fragment("bucket"))
    |> order_by(fragment("bucket DESC"))
  end

  defdelegate order(query, args), to: Aot.QueryUtils
  defdelegate paginate(query, args), to: Aot.QueryUtils

  @spec handle_opts(Ecto.Queryable.t(), keyword()) :: Ecto.Queryable.t()
  def handle_opts(query, opts) do
    [
      with_node: false,
      with_sensor: false,
      with_networks: false,
      assert_hrf: false,
      assert_raw: false,
      for_network: :empty,
      for_networks: :empty,
      for_node: :empty,
      for_nodes: :empty,
      for_sensor: :empty,
      for_sensors: :empty,
      timestamp_op: :empty,
      value_op: :empty,
      located_within: :empty,
      within_distance: :empty,
      as_histogram: :empty,
      value_agg: :empty,
      as_time_buckets: :empty,
      order: :empty,
      paginate: :empty
    ]
    |> Keyword.merge(opts)
    |> apply_opts(query, ObservationQueries)
  end
end
