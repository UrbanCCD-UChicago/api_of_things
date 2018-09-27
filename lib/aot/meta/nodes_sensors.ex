defmodule Aot.Meta.NodesSensors do
  use Ecto.Schema
  import Ecto.Changeset

  schema "nodes_sensors" do
    belongs_to :node, Aot.Meta.Node
    belongs_to :sensor, Aot.Meta.Sensor
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
