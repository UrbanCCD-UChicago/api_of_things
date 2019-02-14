defmodule Aot.M2m.NodeSensor do
  use Ecto.Schema

  @primary_key false
  schema "node_sensors" do
    belongs_to :node, Aot.Nodes.Node,
      foreign_key: :node_vsn,
      references: :vsn,
      type: :string

    belongs_to :sensor, Aot.Sensors.Sensor,
      foreign_key: :sensor_path,
      references: :path,
      type: :string
  end
end
