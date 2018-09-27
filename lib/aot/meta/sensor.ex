defmodule Aot.Meta.Sensor do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sensors" do
    # path
    field :ontology, :string
    field :subsystem, :string
    field :sensor, :string
    field :parameter, :string

    # heuristics range
    field :max_val, :float, default: nil
    field :min_val, :float, default: nil

    # cleaned value's unit of measurement
    field :unit, :string, default: nil

    # reverse relationships
    many_to_many :networks, Aot.Meta.Network, join_through: "networks_sensors"
    many_to_many :nodes, Aot.Meta.Sensor, join_through: "nodes_sensors"
    has_many :observations, Aot.Data.Observation
    has_many :raw_observations, Aot.Data.RawObservation
  end

  @attrs ~W( ontology subsystem sensor parameter max_val min_val unit ) |> Enum.map(&String.to_atom/1)
  @reqd ~W( ontology subsystem sensor parameter ) |> Enum.map(&String.to_atom/1)

  @doc false
  def changeset(sensor, attrs) do
    sensor
    |> cast(attrs, @attrs)
    |> validate_required(@reqd)
  end
end
