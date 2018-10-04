defmodule Aot.NetworkQueries do
  @moduledoc """
  Stored base queries and functions to compose queries for Networks.
  """

  import Aot.QueryUtils, only: [
    apply_opts: 3
  ]

  import Ecto.Query

  import Geo.PostGIS, only: [
    st_contains: 2,
    st_intersects: 2
  ]

  alias Aot.{
    Network,
    NetworkNode,
    NetworkQueries,
    NetworkSensor,
    Node,
    Sensor
  }

  @spec list() :: Ecto.Queryable.t()
  def list, do: Network

  @spec get(binary() | integer()) :: Ecto.Queryable.t()
  def get(id) when is_integer(id), do: where(Network, [n], n.id == ^id)
  def get(id) when is_bitstring(id) do
    case Regex.match?(~r/^\d+$/, id) do
      true -> where(Network, [n], n.id == ^id)
      false -> where(Network, [n], n.slug == ^id)
    end
  end

  @spec include_nodes(Ecto.Queryable.t()) :: Ecto.Query.t()
  def include_nodes(query), do: preload(query, nodes: :networks)

  @spec include_sensors(Ecto.Queryable.t()) :: Ecto.Query.t()
  def include_sensors(query), do: preload(query, sensors: :networks)

  @spec has_node(Ecto.Queryable.t(), Node.t() | integer() | String.t()) :: Ecto.Query.t()
  def has_node(query, %Node{id: id}), do: has_node(query, id)
  def has_node(query, id), do: has_nodes(query, [id])

  @spec has_nodes(Ecto.Queryable.t(), list(Node.t() | integer() | String.t())) :: Ecto.Query.t()
  def has_nodes(query, nodes) when is_list(nodes) do
    node_ids =
      nodes
      |> Enum.map(fn node ->
        case node do
          %Node{id: id} -> id
          id -> id
        end
      end)

    from n in query,
      left_join: nn in NetworkNode, on: n.id == nn.network_id,
      left_join: o in Node, on: o.id == nn.node_id,
      where: o.id in type(^node_ids, {:array, :string}) or o.vsn in type(^node_ids, {:array, :string}),
      distinct: true
  end

  @spec has_sensor(Ecto.Queryable.t(), Sensor.t() | integer() | String.t()) :: Ecto.Query.t()
  def has_sensor(query, %Sensor{id: id}), do: has_sensor(query, id)
  def has_sensor(query, id), do: has_sensors(query, [id])

  @spec has_sensors(Ecto.Queryable.t(), list(Sensor.t() | integer() | String.t())) :: Ecto.Query.t()
  def has_sensors(query, sensors) when is_list(sensors) do
    sensor_ids =
      sensors
      |> Enum.map(fn sensor ->
        case sensor do
          %Sensor{id: id} -> id
          id -> id
        end
      end)
      |> Enum.map(& "#{&1}")

    from n in query,
      left_join: ns in NetworkSensor, on: n.id == ns.network_id,
      left_join: s in Sensor, on: s.id == ns.sensor_id,
      where: fragment("?::text = ANY(?)", s.id, type(^sensor_ids, {:array, :string})) or s.path in type(^sensor_ids, {:array, :string}),
      distinct: true
  end

  @spec bbox_contains(Ecto.Queryable.t(), Geo.PostGIS.Geometry.t()) :: Ecto.Query.t()
  def bbox_contains(query, geom), do: where(query, [n], st_contains(n.bbox, ^geom))

  @spec bbox_intersects(Ecto.Queryable.t(), Geo.PostGIS.Geometry.t()) :: Ecto.Query.t()
  def bbox_intersects(query, geom), do: where(query, [n], st_intersects(n.bbox, ^geom))

  @spec hull_contains(Ecto.Queryable.t(), Geo.PostGIS.Geometry.t()) :: Ecto.Query.t()
  def hull_contains(query, geom), do: where(query, [n], st_contains(n.hull, ^geom))

  @spec hull_intersects(Ecto.Queryable.t(), Geo.PostGIS.Geometry.t()) :: Ecto.Query.t()
  def hull_intersects(query, geom), do: where(query, [n], st_intersects(n.hull, ^geom))

  defdelegate order(query, args), to: Aot.QueryUtils
  defdelegate paginate(query, args), to: Aot.QueryUtils

  @spec handle_opts(Ecto.Queryable.t(), keyword()) :: Ecto.Queryable.t()
  def handle_opts(query, opts \\ []) do
    [
      include_nodes: false,
      include_sensors: false,
      has_node: :empty,
      has_nodes: :empty,
      has_sensor: :empty,
      has_sensors: :empty,
      bbox_contains: :empty,
      bbox_intersects: :empty,
      hull_contains: :empty,
      hull_intersects: :empty,
      order: :empty,
      paginate: :empty
    ]
    |> Keyword.merge(opts)
    |> apply_opts(query, NetworkQueries)
  end
end
