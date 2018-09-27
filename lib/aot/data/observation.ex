defmodule Aot.Data.Observation do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "observations" do
    belongs_to :node, Aot.Meta.Node
    belongs_to :sensor, Aot.Meta.Sensor
    field :timestamp, :naive_datetime
    field :value, :float
  end

  @attrs ~W( node_id sensor_id timestamp value ) |> Enum.map(&String.to_atom/1)

  @doc false
  def changeset(observation, attrs) do
    observation
    |> cast(attrs, @attrs)
    |> validate_required(@attrs)
    |> foreign_key_constraint(:node)
    |> foreign_key_constraint(:sensor)
    |> unique_constraint(:timestamp, name: :obs_unique_id)
  end
end
