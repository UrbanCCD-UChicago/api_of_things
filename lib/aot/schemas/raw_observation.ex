defmodule Aot.RawObservation do
  @moduledoc """
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias Aot.{
    Node,
    Sensor
  }

  @primary_key false
  schema "raw_observations" do
    belongs_to :node, Node, type: :string
    belongs_to :sensor, Sensor
    field :timestamp, :naive_datetime
    field :hrf, :string
    field :raw, :string
  end

  @attrs ~W( node_id sensor_id timestamp hrf raw ) |> Enum.map(&String.to_atom/1)
  @reqd ~W( node_id sensor_id timestamp raw ) |> Enum.map(&String.to_atom/1)

  @doc false
  def changeset(observation, attrs) do
    observation
    |> cast(attrs, @attrs)
    |> validate_required(@reqd)
    |> foreign_key_constraint(:node)
    |> foreign_key_constraint(:sensor)
    |> unique_constraint(:timestamp, name: :raw_obs_unique_id)
  end
end
