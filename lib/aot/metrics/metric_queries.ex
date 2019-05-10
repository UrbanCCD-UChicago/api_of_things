defmodule Aot.Metrics.MetricQueries do
  @moduledoc ""

  import Ecto.Query
  import Geo.PostGIS, only: [st_contains: 2, st_dwithin_in_meters: 3]
  alias Aot.M2m.ProjectNode
  alias Aot.Nodes.Node
  alias Aot.Metrics.Metric
  alias Ecto.Queryable

  # bases

  @doc ""
  @spec list() :: Queryable.t()
  def list, do: from(m in Metric)

  # filter compose

  @doc ""
  @spec for_node(Queryable.t(), binary()) :: Queryable.t()
  def for_node(query, vsn), do: from m in query, where: m.node_vsn == ^vsn

  @doc ""
  @spec for_sensor(Queryable.t(), binary()) :: Queryable.t()
  def for_sensor(query, path), do: from m in query, where: m.sensor_path == ^path

  @doc ""
  @spec for_project(Queryable.t(), binary()) :: Queryable.t()
  def for_project(query, slug) do
    from m in query,
      left_join: n in Node, on: n.vsn == m.node_vsn,
      left_join: pn in ProjectNode, on: pn.node_vsn == n.vsn,
      where: pn.project_slug == ^slug
  end

  @doc ""
  @spec located_within(Queryable.t(), Gem.Polygon.t()) :: Queryable.t()
  def located_within(query, geom), do: from m in query, where: st_contains(^geom, m.location)

  @doc ""
  @spec located_dwithin(Queryable.t(), pos_integer(), Gem.Point.t()) :: Queryable.t()
  def located_dwithin(query, distance, geom), do: from m in query, where: st_dwithin_in_meters(m.location, ^geom, ^distance)

  @doc ""
  @spec timestamp(Queryable.t(), binary(), binary()) :: Queryable.t()
  @spec timestamp(Queryable.t(), binary(), binary(), binary()) :: Queryable.t()
  def timestamp(query, "lt", timestamp), do: from m in query, where: m.timestamp < type(^timestamp, :naive_datetime)
  def timestamp(query, "le", timestamp), do: from m in query, where: m.timestamp <= type(^timestamp, :naive_datetime)
  def timestamp(query, "eq", timestamp), do: from m in query, where: m.timestamp == type(^timestamp, :naive_datetime)
  def timestamp(query, "ge", timestamp), do: from m in query, where: m.timestamp >= type(^timestamp, :naive_datetime)
  def timestamp(query, "gt", timestamp), do: from m in query, where: m.timestamp > type(^timestamp, :naive_datetime)
  def timestamp(query, "between", starts, ends), do: from m in query, where: m.timestamp >= type(^starts, :naive_datetime) and m.timestamp < type(^ends, :naive_datetime)

  @spec value(Queryable.t(), binary(), float()) :: Queryable.t()
  @spec value(Queryable.t(), binary(), float(), float()) :: Queryable.t()
  def value(query, "lt", value), do: from m in query, where: m.value < type(^value, :float)
  def value(query, "le", value), do: from m in query, where: m.value <= type(^value, :float)
  def value(query, "eq", value), do: from m in query, where: m.value == type(^value, :float)
  def value(query, "ge", value), do: from m in query, where: m.value >= type(^value, :float)
  def value(query, "gt", value), do: from m in query, where: m.value > type(^value, :float)
  def value(query, "between", low, high), do: from m in query, where: m.value >= type(^low, :float) and m.value < type(^high, :float)

  def histogram(query, min, max, count),
    do: from m in query,
      group_by: field(m, :node_vsn),
      select: %{
        node_vsn: field(m, :node_vsn),
        histogram: fragment("histogram(value, ?::float, ?::float, ?::integer)", type(^min, :float), type(^max, :float), type(^count, :integer))
      }

  def time_bucket(query, "min", interval),
    do: from m in query,
      group_by: fragment("bucket"),
      order_by: fragment("bucket ASC"),
      select: %{
        bucket: fragment("time_bucket(?::interval, timestamp) AS bucket", type(^interval, :string)),
        value: fragment("min(value) AS value")
      }

  def time_bucket(query, "max", interval),
    do: from m in query,
      group_by: fragment("bucket"),
      order_by: fragment("bucket ASC"),
      select: %{
        bucket: fragment("time_bucket(?::interval, timestamp) AS bucket", type(^interval, :string)),
        value: fragment("max(value) AS value")
      }

  def time_bucket(query, "avg", interval),
    do: from m in query,
      group_by: fragment("bucket"),
      order_by: fragment("bucket ASC"),
      select: %{
        bucket: fragment("time_bucket(?::interval, timestamp) AS bucket", type(^interval, :string)),
        value: fragment("avg(value) AS value")
      }

  def time_bucket(query, "median", interval),
    do: from m in query,
      group_by: fragment("bucket"),
      order_by: fragment("bucket ASC"),
      select: %{
        bucket: fragment("time_bucket(?::interval, timestamp) AS bucket", type(^interval, :string)),
        value: fragment("percentile_cont(0.50::float) within group (order by value)")
      }

  defdelegate order(query, direction, field_name), to: Aot.QueryUtils
  defdelegate paginate(query, page_num, page_size), to: Aot.QueryUtils
end
