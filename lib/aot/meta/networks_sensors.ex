defmodule Aot.Meta.NetworksSensors do
  use Ecto.Schema
  import Ecto.Changeset

  schema "networks_sensors" do
    belongs_to :network, Aot.Meta.Network
    belongs_to :sensor, Aot.Meta.Sensor
  end

  @doc false
  def changeset(network_sensor, attrs) do
    network_sensor
    |> cast(attrs, [:network_id, :sensor_id])
    |> validate_required([:network_id, :sensor_id])
    |> foreign_key_constraint(:network_id)
    |> foreign_key_constraint(:sensor_id)
  end
end
