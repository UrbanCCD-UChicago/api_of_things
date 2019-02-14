defmodule Aot.Observations.ObservationQueries do
  @moduledoc ""

  import Ecto.Query
  import Geo.PostGIS, only: [st_contains: 2, st_dwithin_in_meters: 3]
  alias Aot.M2m.ProjectNode
  alias Aot.Nodes.Node
  alias Aot.Observations.Observation
  alias Ecto.Queryable

  # bases

  @doc ""
  @spec list() :: Queryable.t()
  def list, do: from(o in Observation)

  # filter compose

  @doc ""
  @spec for_node(Queryable.t(), binary()) :: Queryable.t()
  def for_node(query, vsn), do: from o in query, where: o.node_vsn == ^vsn

  @doc ""
  @spec for_sensor(Queryable.t(), binary()) :: Queryable.t()
  def for_sensor(query, path), do: from o in query, where: o.sensor_path == ^path

  @doc ""
  @spec for_project(Queryable.t(), binary()) :: Queryable.t()
  def for_project(query, slug) do
    from o in query,
      left_join: n in Node, on: n.vsn == o.node_vsn,
      left_join: pn in ProjectNode, on: pn.node_vsn == n.vsn,
      where: pn.project_slug == ^slug
  end

  @doc ""
  @spec located_within(Queryable.t(), Geo.Polygon.t()) :: Queryable.t()
  def located_within(query, geom), do: from o in query, where: st_contains(^geom, o.location)

  @doc ""
  @spec located_dwithin(Queryable.t(), pos_integer(), Geo.Point.t()) :: Queryable.t()
  def located_dwithin(query, distance, geom), do: from o in query, where: st_dwithin_in_meters(o.location, ^geom, ^distance)

  @doc ""
  @spec timestamp(Queryable.t(), binary(), binary()) :: Queryable.t()
  @spec timestamp(Queryable.t(), binary(), binary(), binary()) :: Queryable.t()
  def timestamp(query, "lt", timestamp), do: from o in query, where: o.timestamp < type(^timestamp, :naive_datetime)
  def timestamp(query, "le", timestamp), do: from o in query, where: o.timestamp <= type(^timestamp, :naive_datetime)
  def timestamp(query, "eq", timestamp), do: from o in query, where: o.timestamp == type(^timestamp, :naive_datetime)
  def timestamp(query, "ge", timestamp), do: from o in query, where: o.timestamp >= type(^timestamp, :naive_datetime)
  def timestamp(query, "gt", timestamp), do: from o in query, where: o.timestamp > type(^timestamp, :naive_datetime)
  def timestamp(query, "between", starts, ends), do: from o in query, where: o.timestamp >= type(^starts, :naive_datetime) and o.timestamp < type(^ends, :naive_datetime)

  @spec value(Queryable.t(), binary(), float()) :: Queryable.t()
  @spec value(Queryable.t(), binary(), float(), float()) :: Queryable.t()
  def value(query, "lt", value), do: from o in query, where: o.value < type(^value, :float)
  def value(query, "le", value), do: from o in query, where: o.value <= type(^value, :float)
  def value(query, "eq", value), do: from o in query, where: o.value == type(^value, :float)
  def value(query, "ge", value), do: from o in query, where: o.value >= type(^value, :float)
  def value(query, "gt", value), do: from o in query, where: o.value > type(^value, :float)
  def value(query, "between", low, high), do: from o in query, where: o.value >= type(^low, :float) and o.value < type(^high, :float)

  def histogram(query, min, max, count),
    do: from o in query,
      group_by: field(o, :node_vsn),
      select: %{
        node_vsn: field(o, :node_vsn),
        histogram: fragment("histogram(value, ?::float, ?::float, ?::integer)", type(^min, :float), type(^max, :float), type(^count, :integer))
      }

  def time_bucket(query, "min", interval),
    do: from o in query,
      group_by: fragment("bucket"),
      order_by: fragment("bucket ASC"),
      select: %{
        bucket: fragment("time_bucket(?::interval, timestamp) AS bucket", type(^interval, :string)),
        value: fragment("min(value) AS value")
      }

  def time_bucket(query, "max", interval),
    do: from o in query,
      group_by: fragment("bucket"),
      order_by: fragment("bucket ASC"),
      select: %{
        bucket: fragment("time_bucket(?::interval, timestamp) AS bucket", type(^interval, :string)),
        value: fragment("max(value) AS value")
      }

  def time_bucket(query, "avg", interval),
    do: from o in query,
      group_by: fragment("bucket"),
      order_by: fragment("bucket ASC"),
      select: %{
        bucket: fragment("time_bucket(?::interval, timestamp) AS bucket", type(^interval, :string)),
        value: fragment("avg(value) AS value")
      }

  def time_bucket(query, "median", interval),
    do: from o in query,
      group_by: fragment("bucket"),
      order_by: fragment("bucket ASC"),
      select: %{
        bucket: fragment("time_bucket(?::interval, timestamp) AS bucket", type(^interval, :string)),
        value: fragment("percentile_cont(0.50::float) within group (order by value)")
      }

  defdelegate order(query, direction, field_name), to: Aot.QueryUtils
  defdelegate paginate(query, page_num, page_size), to: Aot.QueryUtils
end
