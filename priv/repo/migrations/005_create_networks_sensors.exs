defmodule Aot.MetaRepo.Migrations.CreateNetworksSensors do
  use Ecto.Migration

  def change do
    create table(:networks_sensors) do
      add :network_id, references(:networks, on_delete: :restrict)
      add :sensor_id, references(:sensors, type: :text, on_delete: :restrict)
    end

    create unique_index(:networks_sensors, [:network_id, :sensor_id])
    create index(:networks_sensors, :network_id)
    create index(:networks_sensors, :sensor_id)
  end
end
