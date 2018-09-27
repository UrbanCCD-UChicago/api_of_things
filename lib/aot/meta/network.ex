defmodule Aot.Meta.Network do
  use Ecto.Schema
  import Ecto.Changeset

  schema "networks" do
    field :bbox, Geo.PostGIS.Geometry
    field :hull, Geo.PostGIS.Geometry
    field :name, :string
    field :num_observations, :integer
    field :num_raw_observations, :integer
    field :slug, :string
  end

  @doc false
  def changeset(network, attrs) do
    network
    |> cast(attrs, [:name, :slug, :bbox, :hull, :num_observations, :num_raw_observations])
    |> validate_required([:name, :slug, :bbox, :hull, :num_observations, :num_raw_observations])
  end
end
