defmodule Aot.NodeSensor do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "nodes_sensors" do
    belongs_to :node, Aot.Node
    belongs_to :sensor, Aot.Sensor
  end

  @doc false
  def changeset(node_sensor, attrs) do
    node_sensor
    |> cast(attrs, [:node_id, :sensor_id])
    |> validate_required([:node_id, :sensor_id])
    |> foreign_key_constraint(:node_id)
    |> foreign_key_constraint(:sensor_id)
  end
end
