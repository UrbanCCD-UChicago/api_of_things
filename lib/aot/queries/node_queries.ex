defmodule Aot.NodeQueries do
  @moduledoc """
  Stored base queries and functions to compose queries for Nodes.
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
    NodeQueries,
    NodeSensor,
    Sensor
  }

  @spec list() :: Ecto.Queryable.t()
  def list, do: Node

  @spec get(String.t()) :: Ecto.Queryable.t()
  def get(id), do: where(Node, [n], n.id == ^id or n.vsn == ^id)

  @spec with_networks(Ecto.Queryable.t()) :: Ecto.Queryable.t()
  def with_networks(query), do: preload(query, networks: :nodes)

  @spec with_sensors(Ecto.Queryable.t()) :: Ecto.Queryable.t()
  def with_sensors(query), do: preload(query, sensors: :nodes)

  @spec assert_alive(Ecto.Queryable.t()) :: Ecto.Queryable.t()
  def assert_alive(query), do: where(query, [n], is_nil(n.decommissioned_on))

  @spec assert_dead(Ecto.Queryable.t()) :: Ecto.Queryable.t()
  def assert_dead(query), do: where(query, [n], not is_nil(n.decommissioned_on))

  @spec within_network(Ecto.Queryable.t(), Network.t() | integer() | String.t()) :: Ecto.Queryable.t()
  def within_network(query, %Network{id: id}), do: within_network(query, id)
  def within_network(query, id), do: within_networks(query, [id])

  @spec within_networks(Ecto.Queryable.t(), list(Network.t() | integer() | String.t())) :: Ecto.Queryable.t()
  def within_networks(query, networks) do
    network_ids =
      networks
      |> Enum.map(fn network ->
        case network do
          %Network{id: id} -> id
          id -> id
        end
      end)

    query
    |> join(:left, [n], nn in NetworkNode, n.id == nn.node_id)
    |> join(:left, [nn], e in Network, nn.network_id == e.id)
    |> where([e], e.id in ^network_ids or e.slug in ^network_ids)
  end

  @spec has_sensor(Ecto.Queryable.t(), Sensor.t() | integer() | String.t()) :: Ecto.Queryable.t()
  def has_sensor(query, %Sensor{id: id}), do: has_sensor(query, id)
  def has_sensor(query, id), do: has_sensors(query, [id])

  @spec has_sensors(Ecto.Queryable.t(), list(Sensor.t() | integer() | String.t())) :: Ecto.Queryable.t()
  def has_sensors(query, sensors) do
    sensor_ids =
      sensors
      |> Enum.map(fn sensor ->
        case sensor do
          %Sensor{id: id} -> id
          id -> id
        end
      end)

    query
    |> join(:left, [n], ns in NodeSensor, n.id == ns.node_id)
    |> join(:left, [ns], s in Sensor, ns.sensor_id == s.id)
    |> where([s], s.id in ^sensor_ids or s.path in ^sensor_ids)
  end

  @spec located_within(Ecto.Queryable.t(), Geo.PostGIS.Geometry.t()) :: Ecto.Queryable.t()
  def located_within(query, geom), do: where(query, [n], st_contains(^geom, n.location))

  @spec within_distance(Ecto.Queryable.t(), {Geo.PostGIS.Geometry.t(), float()}) :: Ecto.Queryable.t()
  def within_distance(query, {geom, meters}), do: where(query, [n], st_dwithin_in_meters(n.location, ^geom, ^meters))

  @spec commissioned_on_op(Ecto.Queryable.t(), {:between | :eq | :ge | :gt | :in | :le | :lt, NaiveDateTime.t()}) :: Ecto.Queryable.t()
  def commissioned_on_op(query, {op, value}), do: typed_field_op(query, :commissioned_on, op, value, :naive_datetime)

  @spec decommissioned_on_op(Ecto.Queryable.t(), {:between | :eq | :ge | :gt | :in | :le | :lt, NaiveDateTime.t()}) :: Ecto.Queryable.t()
  def decommissioned_on_op(query, {op, value}), do: typed_field_op(query, :decommissioned_on, op, value, :naive_datetime)

  defdelegate order(query, args), to: Aot.QueryUtils
  defdelegate paginate(query, args), to: Aot.QueryUtils

  @spec handle_opts(Ecto.Queryable.t(), keyword()) :: Ecto.Queryable.t()
  def handle_opts(query, opts \\ []) do
    [
      with_networks: false,
      with_sensors: false,
      assert_alive: false,
      assert_dead: false,
      within_network: :empty,
      within_networks: :empty,
      has_sensor: :empty,
      has_sensors: :empty,
      located_within: :empty,
      within_distance: :empty,
      commissioned_on_op: :empty,
      decommissioned_on_op: :empty,
      order: :empty,
      paginate: :empty
    ]
    |> Keyword.merge(opts)
    |> apply_opts(query, NodeQueries)
  end
end
