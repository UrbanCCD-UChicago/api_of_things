defmodule Aot.NodeQueries do
  @moduledoc """
  """

  import Aot.QueryUtils, only: [
    apply_opts: 3
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

  def list,
    do: from node in Node

  def get(id),
    do: from node in Node,
      where: node.id == ^id

  # BOOLEAN COMPOSE

  def include_networks(query),
    do: from node in query,
      preload: [networks: :nodes]

  def include_sensors(query),
    do: from node in query,
      preload: [sensors: :nodes]

  def assert_alive(query),
    do: from node in query,
      where: is_nil(node.decommissioned_on)

  def assert_dead(query),
    do: from node in query,
      where: not is_nil(node.decommissioned_on)


  # FILTER COMPOSE

  def within_network(query, %Network{slug: slug}),
    do: within_network(query, slug)

  def within_network(query, slug) when is_binary(slug),
    do: within_networks(query, [slug])

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
      where: net.slug in ^slugs
  end

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

  def has_sensor(query, %Sensor{path: path}),
    do: has_sensor(query, path)

  def has_sensor(query, path) when is_binary(path),
    do: has_sensors(query, [path])

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
      where: sensor.path in ^paths
  end

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

  def located_within_distance(query, {meters, geom}),
    do: from node in query,
      where: st_dwithin_in_meters(node.location, ^geom, ^meters)

  def located_within(query, geom),
    do: from node in query,
      where: st_contains(^geom, node.location)

  def commissioned_on(query, {:lt, value}), do: from node in query, where: node.commissioned_on < ^value
  def commissioned_on(query, {:le, value}), do: from node in query, where: node.commissioned_on <= ^value
  def commissioned_on(query, {:eq, value}), do: from node in query, where: node.commissioned_on == ^value
  def commissioned_on(query, {:ge, value}), do: from node in query, where: node.commissioned_on >= ^value
  def commissioned_on(query, {:gt, value}), do: from node in query, where: node.commissioned_on > ^value

  def decommissioned_on(query, {:lt, value}), do: from node in query, where: node.decommissioned_on < ^value
  def decommissioned_on(query, {:le, value}), do: from node in query, where: node.decommissioned_on <= ^value
  def decommissioned_on(query, {:eq, value}), do: from node in query, where: node.decommissioned_on == ^value
  def decommissioned_on(query, {:ge, value}), do: from node in query, where: node.decommissioned_on >= ^value
  def decommissioned_on(query, {:gt, value}), do: from node in query, where: node.decommissioned_on > ^value

  defdelegate order(query, args), to: Aot.QueryUtils
  defdelegate paginate(query, args), to: Aot.QueryUtils

  # OTHER ACTION HELPERS

  def handle_opts(query, opts \\ []) do
    [
      include_networks: false,
      include_sensors: false,
      assert_alive: false,
      assert_dead: false,
      has_network: :empty,
      has_networks: :empty,
      has_networks_exact: :empty,
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
    |> apply_opts(query, NodeQueries)
  end
end




# defmodule Aot.NodeQueries do

#   def commissioned_on_op(query, {op, value}), do: typed_field_op(query, :commissioned_on, op, value, :naive_datetime)

#   def decommissioned_on_op(query, {op, value}), do: typed_field_op(query, :decommissioned_on, op, value, :naive_datetime)

#   defdelegate order(query, args), to: Aot.QueryUtils
#   defdelegate paginate(query, args), to: Aot.QueryUtils

#   @spec handle_opts(Ecto.Queryable.t(), keyword()) :: Ecto.Queryable.t()
#   def handle_opts(query, opts \\ []) do
#     [
#       include_networks: false,
#       include_sensors: false,
#       assert_alive: false,
#       assert_dead: false,
#       within_network: :empty,
#       within_networks: :empty,
#       has_sensor: :empty,
#       has_sensors: :empty,
#       located_within: :empty,
#       within_distance: :empty,
#       commissioned_on_op: :empty,
#       decommissioned_on_op: :empty,
#       order: :empty,
#       paginate: :empty
#     ]
#     |> Keyword.merge(opts)
#     |> apply_opts(query, NodeQueries)
#   end
# end
