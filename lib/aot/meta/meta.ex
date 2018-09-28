defmodule Aot.Meta do
  import Ecto.Query, warn: false

  import Geo.PostGIS, only: [
    st_contains: 2,
    st_dwithin_in_meters: 3,
    st_intersects: 2,
    st_within: 2
  ]

  alias Aot.Repo

  alias Aot.Meta.{
    Network,
    Node,
    Sensor,
    NetworksNodes,
    NetworksSensors,
    NodesSensors
  }

  # GENERAL PURPOSE UTIL FUNCTIONS

  def boolean_compose(query, false, _func), do: query
  def boolean_compose(query, true, func), do: apply(__MODULE__, func, [query])

  def filter_compose(query, :empty, _func), do: query
  def filter_compose(query, value, func), do: apply(__MODULE__, func, [query, value])

  # NETWORK QUERY HELPERS

  def network_list, do: Network

  def network_get(id) when is_integer(id), do: where(Network, [n], n.id == ^id)
  def network_get(id) when is_bitstring(id) do
    case Regex.match?(~r/^\d+$/, id) do
      true -> where(Network, [n], n.id == ^id)
      false -> where(Network, [n], n.slug == ^id)
    end
  end

  def network_with_nodes(query), do: preload(query, nodes: :networks)

  def network_with_sensors(query), do: preload(query, sensors: :networks)

  def network_has_node(query, %Node{id: id}), do: network_has_node(query, id)
  def network_has_node(query, id) do
    query
    |> join(:left, [n], nn in NetworksNodes, n.id == nn.network_id)
    |> join(:left, [nn], no in Node, nn.node_id == no.id)
    |> where([no], no.id == ^id)
  end

  def network_has_nodes(query, nodes) when is_list(nodes) do
    node_ids =
      nodes
      |> Enum.map(fn node ->
        case node do
          %Node{id: id} -> id
          id -> id
        end
      end)

    query
    |> join(:left, [n], nn in NetworksNodes, n.id == nn.network_id)
    |> join(:left, [nn], no in Node, nn.node_id == no.id)
    |> where([no], no.id in ^node_ids)
  end

  def network_has_sensor(query, %Sensor{id: id}), do: network_has_sensor(query, id)
  def network_has_sensor(query, id) do
    query
    |> join(:left, [n], ns in NetworksSensors, n.id == ns.network_id)
    |> join(:left, [ns], s in Sensor, ns.sensor_id == s.id)
    |> where([s], s.id == ^id)
  end

  def network_has_sensors(query, sensors) when is_list(sensors) do
    sensor_ids =
      sensors
      |> Enum.map(fn sensor ->
        case sensor do
          %Sensor{id: id} -> id
          id -> id
        end
      end)

    query
    |> join(:left, [n], ns in NetworksSensors, n.id == ns.network_id)
    |> join(:left, [ns], s in Sensor, ns.sensor_id == s.id)
    |> where([s], s.id in ^sensor_ids)
  end

  def network_bbox_intersects(query, geom), do: where(query, [n], st_intersects(n.bbox, ^geom))

  def network_bbox_contains(query, geom), do: where(query, [n], st_contains(n.bbox, ^geom))

  def network_hull_intersects(query, geom), do: where(query, [n], st_intersects(n.hull, ^geom))

  def network_hull_contains(query, geom), do: where(query, [n], st_contains(n.hull, ^geom))

  def network_opts(query, opts \\ []) do
    opts =
      [
        with_nodes: false,
        with_sensors: false,
        has_node: :empty,
        has_nodes: :empty,
        has_sensor: :empty,
        has_sensors: :empty,
        bbox_intersects: :empty,
        bbox_contains: :empty,
        hull_intersects: :empty,
        hull_contains: :empty
      ]
      |> Keyword.merge(opts)

    query
    |> boolean_compose(opts[:with_nodes], :network_with_nodes)
    |> boolean_compose(opts[:with_sensors], :network_with_sensors)
    |> filter_compose(opts[:has_node], :network_has_node)
    |> filter_compose(opts[:has_nodes], :network_has_nodes)
    |> filter_compose(opts[:has_sensor], :network_has_sensor)
    |> filter_compose(opts[:has_sensors], :network_has_sensors)
    |> filter_compose(opts[:bbox_intersects], :network_bbox_intersects)
    |> filter_compose(opts[:bbox_contains], :network_bbox_contains)
    |> filter_compose(opts[:hull_intersects], :network_hull_intersects)
    |> filter_compose(opts[:hull_contains], :network_hull_contains)
  end

  # NETWORK ACTIONS

  def list_networks(opts \\ []) do
    network_list()
    |> network_opts(opts)
    |> Repo.all()
  end

  def get_network!(id, opts \\ []) do
    network_get(id)
    |> network_opts(opts)
    |> Repo.one!()
  end

  def create_network(attrs \\ %{}) do
    %Network{}
    |> Network.changeset(attrs)
    |> Repo.insert()
  end

  def update_network(%Network{} = network, attrs) do
    network
    |> Network.changeset(attrs)
    |> Repo.update()
  end

  def change_network(%Network{} = network), do: Network.changeset(network, %{})

  # NODE QUERY HELPERS

  def node_list, do: Node

  def node_get(id) when is_integer(id), do: node_get(Integer.to_string(id))
  def node_get(id) when is_bitstring(id) do
    case String.length(id) do
      3 -> where(Node, [n], n.vsn == ^id)
      _ -> where(Node, [n], n.id == ^id)
    end
  end

  def node_with_networks(query), do: preload(query, networks: :nodes)

  def node_with_sensors(query), do: preload(query, sensors: :nodes)

  def node_in_network(query, %Network{id: id}), do: node_in_network(query, id)
  def node_in_network(query, id) do
    query
    |> join(:left, [no], nn in NetworksNodes, no.id == nn.node_id)
    |> join(:left, [nn], ne in Network, nn.network_id == ne.id)
    |> where([ne], ne.id == ^id)
  end

  def node_located_within(query, {point, distance}), do: where(query, [n], st_dwithin_in_meters(n.location, ^point, ^distance))
  def node_located_within(query, geometry), do: where(query, [n], st_within(^geometry, n.location))

  def node_opts(query, opts \\ []) do
    opts =
      [
        with_networks: false,
        with_sensors: false,
        in_network: :empty,
        located_within: :empty
      ]
      |> Keyword.merge(opts)

    query
    |> boolean_compose(opts[:with_networks], :node_with_networks)
    |> boolean_compose(opts[:with_sensors], :node_with_sensors)
    |> filter_compose(opts[:in_network], :node_in_network)
    |> filter_compose(opts[:located_within], :node_located_within)
  end

  # NODE ACTIONS

  def list_nodes(opts \\ []) do
    node_list()
    |> node_opts(opts)
    |> Repo.all()
  end

  def get_node!(id, opts \\ []) do
    node_get(id)
    |> node_opts(opts)
    |> Repo.one!()
  end

  def create_node(attrs \\ %{}) do
    %Node{}
    |> Node.changeset(attrs)
    |> Repo.insert()
  end

  def update_node(%Node{} = node, attrs) do
    node
    |> Node.changeset(attrs)
    |> Repo.update()
  end

  def change_node(%Node{} = node), do: Node.changeset(node, %{})

  # SENSOR QUERY HELPERS

  def sensor_list, do: Sensor

  def sensor_get(id), do: where(Sensor, [s], s.id == ^id)

  def sensor_with_networks(query), do: preload(query, networks: :sensors)

  def sensor_with_nodes(query), do: preload(query, nodes: :sensors)

  def sensor_opts(query, opts \\ []) do
    opts =
      [
        with_networks: false,
        with_nodes: false
      ]
      |> Keyword.merge(opts)

    query
    |> boolean_compose(opts[:with_networks], :sensor_with_networks)
    |> boolean_compose(opts[:with_nodes], :sensor_with_nodes)
  end

  # SENSOR ACTIONS

  def list_sensors(opts \\ []) do
    sensor_list()
    |> sensor_opts(opts)
    |> Repo.all()
  end

  def get_sensor!(id, opts \\ []) do
    sensor_get(id)
    |> sensor_opts(opts)
    |> Repo.one!()
  end

  def create_sensor(attrs \\ %{}) do
    %Sensor{}
    |> Sensor.changeset(attrs)
    |> Repo.insert()
  end

  def update_sensor(%Sensor{} = sensor, attrs) do
    sensor
    |> Sensor.changeset(attrs)
    |> Repo.update()
  end

  def change_sensor(%Sensor{} = sensor), do: Sensor.changeset(sensor, %{})

  # M2M UPSERTS

  def upsert_network_node(attrs \\ %{}) do
    %NetworksNodes{}
    |> NetworksNodes.changeset(attrs)
    |> Repo.insert(on_conflict: :nothing)
  end

  def upsert_network_sensor(attrs \\ %{}) do
    %NetworksSensors{}
    |> NetworksSensors.changeset(attrs)
    |> Repo.insert(on_conflict: :nothing)
  end

  def upsert_node_sensor(attrs \\ %{}) do
    %NodesSensors{}
    |> NodesSensors.changeset(attrs)
    |> Repo.insert(on_conflict: :nothing)
  end
end
