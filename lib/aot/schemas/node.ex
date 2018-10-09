defmodule Aot.Node do
  @moduledoc """
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias Aot.{
    Network,
    NetworkNode,
    NodeSensor,
    Observation,
    RawObservation,
    Sensor
  }

  alias Geo.PostGIS.Geometry

  @primary_key {:id, :string, autogenerate: false}
  schema "nodes" do
    # alternate key
    field :vsn, :string

    # location metadata
    field :location, Geometry
    field :latitude, :float, virtual: true
    field :longitude, :float, virtual: true

    # human metadata
    field :description, :string, default: nil
    field :address, :string, default: nil

    # up/down timestamps
    field :commissioned_on, :naive_datetime
    field :decommissioned_on, :naive_datetime, default: nil

    # reverse relationships
    has_many :observations, Observation
    has_many :raw_observations, RawObservation

    many_to_many :networks, Network,
      join_through: NetworkNode,
      join_keys: [node_id: :id, network_slug: :slug]

    many_to_many :sensors, Sensor,
      join_through: NodeSensor,
      join_keys: [node_id: :id, sensor_path: :path]
  end

  @attrs ~W( id vsn latitude longitude description address commissioned_on decommissioned_on ) |> Enum.map(&String.to_atom/1)
  @reqd ~W( id vsn latitude longitude commissioned_on ) |> Enum.map(&String.to_atom/1)

  @doc false
  def changeset(node, attrs) do
    node
    |> cast(attrs, @attrs)
    |> validate_required(@reqd)
    |> unique_constraint(:id, name: :nodes_pkey)
    |> unique_constraint(:vsn)
    |> put_location()
  end

  defp put_location(%Ecto.Changeset{valid?: true} = cs) do
    lon_change = get_change(cs, :longitude, nil)
    lat_change = get_change(cs, :latitude, nil)
    case !is_nil(lon_change) or !is_nil(lat_change) do
      false ->
        cs

      true ->
        loc = get_field(cs, :location, %Geo.Point{coordinates: {0, 0}})
        lon = lon_change || Enum.at(Tuple.to_list(loc.coordinates), 0)
        lat = lat_change || Enum.at(Tuple.to_list(loc.coordinates), 1)
        point = %Geo.Point{srid: 4326, coordinates: {lon, lat}}
        put_change(cs, :location, point)
    end
  end

  defp put_location(cs), do: cs
end
