defmodule Aot.NodeSensor do
  use Ecto.Schema
  import Ecto.Changeset

  schema "nodes_sensors" do
    belongs_to :node, Aot.Node,
      foreign_key: :node_vsn,
      references: :vsn,
      type: :string

    belongs_to :sensor, Aot.Sensor,
      foreign_key: :sensor_path,
      references: :path,
      type: :string
  end

  @params ~W(node_vsn sensor_path) |> Enum.map(&String.to_atom/1)

  @doc false
  def changeset(node_sensor, attrs) do
    node_sensor
    |> cast(attrs, @params)
    |> validate_required(@params)
    |> foreign_key_constraint(:node_vsn)
    |> foreign_key_constraint(:sensor_path)
    |> unique_constraint(:node_vsn, name: :nodes_sensors_uniq)
  end
end
