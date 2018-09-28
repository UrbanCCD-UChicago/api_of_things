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
    belongs_to :node, Node
    belongs_to :sensor, Sensor
    field :timestamp, :naive_datetime
    field :value, :float
    field :raw?, :boolean, default: false
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
