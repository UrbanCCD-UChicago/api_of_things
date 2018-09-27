defmodule Aot.Data.Observation do
  use Ecto.Schema
  import Ecto.Changeset


  schema "observations" do
    belongs_to :node, Aot.Meta.Node
    belongs_to :sensor, Aot.Meta.Sensor
    field :timestamp, :naive_datetime
    field :value, :float
  end

  @doc false
  def changeset(observation, attrs) do
    observation
    |> cast(attrs, [:node, :sensor, :timestamp, :value])
    |> validate_required([:node, :sensor, :timestamp, :value])
  end
end
