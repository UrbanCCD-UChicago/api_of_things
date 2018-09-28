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
  def list, do: order_by(Observation, [o], desc: o.timestamp)

  @spec with_node(Ecto.Queryable.t()) :: Ecto.Queryable.t()
  def with_node(query), do: preload(query, :node)

  @spec with_sensor(Ecto.Queryable.t()) :: Ecto.Queryable.t()
  def with_sensor(query), do: preload(query, :sensor)

  @spec with_networks(Ecto.Queryable.t()) :: Ecto.Queryable.t()
  def with_networks(query), do: preload(query, node: :networks)

  @spec assert_hrf(Ecto.Queryable.t()) :: Ecto.Queryable.t()
  def assert_hrf(query), do: where(query, [o], o.is_raw? == false)

  @spec assert_raw(Ecto.Queryable.t()) :: Ecto.Queryable.t()
  def assert_raw(query), do: where(query, [o], o.is_raw? == true)

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

    query
    |> join(:left, [o], nn in NetworkNode, o.node_id == nn.node_id)
    |> join(:left, [nn], n in Network, nn.network_id == n.id)
    |> where([e], e.id in ^network_ids or e.slug in ^network_ids)
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

    query
    |> join(:left, [o], n in Node, o.node_id == n.id)
    |> where([n], n.id in ^node_ids or n.vsn in ^node_ids)
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

    query
    |> join(:left, [o], s in Sensor, o.sensor_id == s.id)
    |> where([s], s.id in ^sensor_ids or s.path in ^sensor_ids)
  end

  @spec timestamp_op(Ecto.Queryable.t(), {:between | :eq | :ge | :gt | :in | :le | :lt, NaiveDateTime.t()}) :: Ecto.Queryable.t()
  def timestamp_op(query, {op, value}), do: typed_field_op(query, :timestamp, op, value, :naive_datetime)

  @spec value_op(Ecto.Queryable.t(), {:between | :eq | :ge | :gt | :in | :le | :lt, NaiveDateTime.t()}) :: Ecto.Queryable.t()
  def value_op(query, {op, value}), do: field_op(query, :value, op, value)

  @spec located_within(Ecto.Queryable.t(), Geo.PostGIS.Geometry.t()) :: Ecto.Queryable.t()
  def located_within(query, geom) do
    query
    |> join(:left, [o], n in Node, o.node_id == n.id)
    |> where([n], st_contains(^geom, n.location))
  end

  @spec within_distance(Ecto.Queryable.t(), {Geo.PostGIS.Geometry.t(), float()}) :: Ecto.Queryable.t()
  def within_distance(query, {geom, meters}) do
    query
    |> join(:left, [o], n in Node, o.node_id == n.id)
    |> where([n], st_dwithin_in_meters(n.location, ^geom, ^meters))
  end

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
      within_distance: :empty
    ]
    |> Keyword.merge(opts)
    |> apply_opts(query, ObservationQueries)
  end
end
