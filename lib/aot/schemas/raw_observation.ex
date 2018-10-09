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
    field :timestamp, :naive_datetime
    field :hrf, :float, default: nil
    field :raw, :float

    belongs_to :node, Node,
      foreign_key: :node_id,
      references: :id,
      type: :string

    belongs_to :sensor, Sensor,
      foreign_key: :sensor_path,
      references: :path,
      type: :string
  end

  @attrs ~W( node_id sensor_path timestamp hrf raw ) |> Enum.map(&String.to_atom/1)
  @reqd ~W( node_id sensor_path timestamp raw ) |> Enum.map(&String.to_atom/1)

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
