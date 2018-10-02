defmodule Aot.NetworkSensor do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "networks_sensors" do
    belongs_to :network, Aot.Network
    belongs_to :sensor, Aot.Sensor
  end

  @doc false
  def changeset(network_sensor, attrs) do
    network_sensor
    |> cast(attrs, [:network_id, :sensor_id])
    |> validate_required([:network_id, :sensor_id])
    |> foreign_key_constraint(:network_id)
    |> foreign_key_constraint(:sensor_id)
    |> unique_constraint(:network_id, name: :networks_sensors_uniq)
  end
end
