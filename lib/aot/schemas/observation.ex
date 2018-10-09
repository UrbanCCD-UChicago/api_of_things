defmodule Aot.Observation do
  @moduledoc """
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias Aot.{
    Node,
    Sensor
  }

  @primary_key false
  schema "observations" do
    field :timestamp, :naive_datetime
    field :value, :float

    belongs_to :node, Node,
      foreign_key: :node_id,
      references: :id,
      type: :string

    belongs_to :sensor, Sensor,
      foreign_key: :sensor_path,
      references: :path,
      type: :string
  end

  @attrs ~W( node_id sensor_path timestamp value ) |> Enum.map(&String.to_atom/1)

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
