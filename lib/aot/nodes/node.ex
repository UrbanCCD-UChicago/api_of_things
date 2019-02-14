defmodule Aot.Nodes.Node do
  @moduledoc ""

  use Ecto.Schema
  import Ecto.Changeset
  alias Ecto.Changeset

  @primary_key {:vsn, :string, autogenerate: false}
  @derive {Phoenix.Param, key: :vsn}
  schema "nodes" do
    # field :vsn, :string
    field :id, :string
    field :location, Geo.PostGIS.Geometry
    field :address, :string, default: nil
    field :description, :string, default: nil

    field :lon, :float, virtual: true
    field :lat, :float, virtual: true

    # relationships
    has_many :observations, Aot.Observations.Observation

    many_to_many :projects, Aot.Projects.Project,
      join_through: "project_nodes",
      join_keys: [node_vsn: :vsn, project_slug: :slug]

    many_to_many :sensors, Aot.Sensors.Sensor,
      join_through: "node_sensors",
      join_keys: [node_vsn: :vsn, sensor_path: :path]
  end

  @attrs ~w| vsn id address description lon lat |a
  @reqd ~w| vsn id lon lat |a

  @doc false
  def changeset(node, attrs) do
    node
    |> cast(attrs, @attrs)
    |> validate_required(@reqd)
    |> unique_constraint(:vsn, name: :nodes_pkey)
    |> put_location()
  end

  defp put_location(%Changeset{valid?: true} = cs) do
    lon = get_field(cs, :lon)
    lat = get_field(cs, :lat)

    pt = %Geo.Point{srid: 4326, coordinates: {lon, lat}}
    put_change(cs, :location, pt)
  end

  defp put_location(cs), do: cs
end
