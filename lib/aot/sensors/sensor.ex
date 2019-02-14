defmodule Aot.Sensors.Sensor do
  @moduledoc ""

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:path, :string, autogenerate: false}
  @derive {Phoenix.Param, key: :path}
  schema "sensors" do
    # field :path, :string
    field :data_sheet, :string, default: nil
    field :uom, :string, default: nil
    field :max, :float, default: nil
    field :min, :float, default: nil

    # relationships
    has_many :observations, Aot.Observations.Observation

    many_to_many :nodes, Aot.Nodes.Node,
      join_through: "node_sensors",
      join_keys: [sensor_path: :path, node_vsn: :vsn]
  end

  @attrs ~w| path data_sheet uom min max |a
  @reqd [:path]

  @doc false
  def changeset(sensor, attrs) do
    sensor
    |> cast(attrs, @attrs)
    |> validate_required(@reqd)
    |> unique_constraint(:path, name: :sensors_pkey)
  end
end
