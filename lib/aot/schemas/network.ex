defmodule Aot.Network do
  @moduledoc """
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias Aot.{
    Node,
    Sensor
  }

  alias Geo.PostGIS.Geometry

  @derive {Phoenix.Param, key: :slug}
  schema "networks" do
    # identification
    field :name, :string
    field :slug, :string

    # source info
    field :archive_url, :string
    field :recent_url, :string

    # provenance metadata
    field :first_observation, :naive_datetime, default: nil
    field :latest_observation, :naive_datetime, default: nil

    # node metadata
    field :bbox, Geometry, default: nil
    field :hull, Geometry, default: nil

    # reverse relationships
    many_to_many :nodes, Node, join_through: "networks_nodes"
    many_to_many :sensors, Sensor, join_through: "networks_sensors"
  end

  @attrs ~W( name bbox hull archive_url recent_url first_observation latest_observation ) |> Enum.map(&String.to_atom/1)
  @reqd ~W( name archive_url recent_url ) |> Enum.map(&String.to_atom/1)
  @https ~r/https/

  @doc false
  def changeset(network, attrs) do
    network
    |> cast(attrs, @attrs)
    |> validate_required(@reqd)
    |> unique_constraint(:name)
    |> unique_constraint(:archive_url)
    |> unique_constraint(:recent_url)
    |> validate_format(:archive_url, @https)
    |> validate_format(:recent_url, @https)
    |> put_slug()
  end

  defp put_slug(%Ecto.Changeset{valid?: true, changes: %{name: name}} = cs) do
    slug = Slug.slugify(name)
    put_change(cs, :slug, slug)
  end

  defp put_slug(cs), do: cs
end
