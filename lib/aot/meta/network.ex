defmodule Aot.Meta.Network do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Phoenix.Param, key: :slug}
  schema "networks" do
    # identification
    field :name, :string
    field :slug, :string

    # node metadata
    field :bbox, Geo.PostGIS.Geometry, default: nil
    field :hull, Geo.PostGIS.Geometry, default: nil

    # observation metadata
    field :num_observations, :integer, default: 0
    field :num_raw_observations, :integer, default: 0

    # reverse relationships
    many_to_many :nodes, Aot.Meta.Node, join_through: "networks_nodes"
    many_to_many :sensors, Aot.Meta.Sensor, join_through: "networks_sensors"
  end

  @attrs ~W( name bbox hull num_observations num_raw_observations ) |> Enum.map(&String.to_atom/1)
  @reqd ~W( name ) |> Enum.map(&String.to_atom/1)

  @doc false
  def changeset(network, attrs) do
    network
    |> cast(attrs, @attrs)
    |> validate_required(@reqd)
    |> put_slug()
  end

  defp put_slug(%Ecto.Changeset{valid?: true, changes: %{name: name}} = cs) do
    slug = Slug.slugify(name)
    put_change(cs, :slug, slug)
  end

  defp put_slug(cs), do: cs
end
