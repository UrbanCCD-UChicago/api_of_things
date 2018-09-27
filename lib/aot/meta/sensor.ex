defmodule Aot.Meta.Sensor do
  use Ecto.Schema
  import Ecto.Changeset


  schema "sensors" do
    field :max_val, :float
    field :min_val, :float
    field :ontology, :string
    field :parameter, :string
    field :sensor, :string
    field :subsystem, :string
    field :unit, :string
  end

  @doc false
  def changeset(sensor, attrs) do
    sensor
    |> cast(attrs, [:ontology, :subsystem, :sensor, :parameter, :unit, :min_val, :max_val])
    |> validate_required([:ontology, :subsystem, :sensor, :parameter, :unit, :min_val, :max_val])
  end
end
