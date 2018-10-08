defmodule Aot.NodeSensor do
  use Ecto.Schema
  import Ecto.Changeset

  schema "nodes_sensors" do
    belongs_to :node, Aot.Node, type: :string
    belongs_to :sensor, Aot.Sensor
  end

  @doc false
  def changeset(node_sensor, attrs) do
    node_sensor
    |> cast(attrs, [:node_id, :sensor_id])
    |> validate_required([:node_id, :sensor_id])
    |> foreign_key_constraint(:node_id)
    |> foreign_key_constraint(:sensor_id)
    |> unique_constraint(:node_id, name: :nodes_sensors_uniq)
  end
end
