defmodule Aot.NetworkSensor do
  use Ecto.Schema
  import Ecto.Changeset

  schema "networks_sensors" do
    belongs_to :network, Aot.Network,
      foreign_key: :network_slug,
      references: :slug,
      type: :string

    belongs_to :sensor, Aot.Sensor,
      foreign_key: :sensor_path,
      references: :path,
      type: :string
  end

  @doc false
  def changeset(network_sensor, attrs) do
    network_sensor
    |> cast(attrs, [:network_slug, :sensor_path])
    |> validate_required([:network_slug, :sensor_path])
    |> foreign_key_constraint(:network_slug)
    |> foreign_key_constraint(:sensor_path)
    |> unique_constraint(:network_slug, name: :networks_sensors_uniq)
  end
end
