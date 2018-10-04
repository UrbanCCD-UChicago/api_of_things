defmodule Aot.RawObservationQueries do
  @moduledoc """
  Stored base queries and functions to compose queries for RawObservations.
  """

  import Aot.QueryUtils, only: [
    apply_opts: 3,
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
    RawObservation,
    RawObservationQueries,
    Sensor
  }

  @spec list() :: Ecto.Queryable.t()
  def list, do: RawObservation

  @spec include_node(Ecto.Queryable.t()) :: Ecto.Queryable.t()
  def include_node(query), do: preload(query, :node)

  @spec include_sensor(Ecto.Queryable.t()) :: Ecto.Queryable.t()
  def include_sensor(query), do: preload(query, :sensor)

  @spec include_networks(Ecto.Queryable.t()) :: Ecto.Queryable.t()
  def include_networks(query), do: preload(query, node: :networks)

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

  defdelegate order(query, args), to: Aot.QueryUtils
  defdelegate paginate(query, args), to: Aot.QueryUtils

  @spec handle_opts(Ecto.Queryable.t(), keyword()) :: Ecto.Queryable.t()
  def handle_opts(query, opts) do
    [
      include_node: false,
      include_sensor: false,
      include_networks: false,
      for_network: :empty,
      for_networks: :empty,
      for_node: :empty,
      for_nodes: :empty,
      for_sensor: :empty,
      for_sensors: :empty,
      timestamp_op: :empty,
      located_within: :empty,
      within_distance: :empty,
      order: :empty,
      paginate: :empty
    ]
    |> Keyword.merge(opts)
    |> apply_opts(query, RawObservationQueries)
  end
end
