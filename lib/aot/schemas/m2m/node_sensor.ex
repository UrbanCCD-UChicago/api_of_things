defmodule Aot.NodeSensor do
  use Ecto.Schema
  import Ecto.Changeset

  schema "nodes_sensors" do
    belongs_to :node, Aot.Node, foreign_key: :node_id, references: :id, type: :string
    belongs_to :sensor, Aot.Sensor, foreign_key: :sensor_path, references: :path, type: :string
  end

  @doc false
  def changeset(node_sensor, attrs) do
    node_sensor
    |> cast(attrs, [:node_id, :sensor_path])
    |> validate_required([:node_id, :sensor_path])
    |> foreign_key_constraint(:node_id)
    |> foreign_key_constraint(:sensor_path)
    |> unique_constraint(:node_id, name: :nodes_sensors_uniq)
  end
end
