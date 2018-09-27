defmodule Aot.Data.RawObservation do
  use Ecto.Schema
  import Ecto.Changeset


  schema "raw_observations" do
    belongs_to :node, Aot.Meta.Node
    belongs_to :sensor, Aot.Meta.Sensor
    field :timestamp, :naive_datetime
    field :value, :float

    timestamps()
  end

  @doc false
  def changeset(raw_observation, attrs) do
    raw_observation
    |> cast(attrs, [:node, :sensor, :timestamp, :value])
    |> validate_required([:node, :sensor, :timestamp, :value])
  end
end
