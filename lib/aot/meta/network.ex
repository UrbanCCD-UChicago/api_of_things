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

    many_to_many :nodes, Aot.Meta.Node, join_through: "networks_nodes"
    many_to_many :sensors, Aot.Meta.Sensor, join_through: "networks_sensors"
  end

  @doc false
  def changeset(network, attrs) do
    network
    |> cast(attrs, [:name, :slug, :bbox, :hull, :num_observations, :num_raw_observations])
    |> validate_required([:name, :slug, :bbox, :hull, :num_observations, :num_raw_observations])
  end
end
