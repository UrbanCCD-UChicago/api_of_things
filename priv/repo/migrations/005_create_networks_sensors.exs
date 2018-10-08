defmodule Aot.Repo.Migrations.CreateNetworksSensors do
  use Ecto.Migration

  def change do
    create table(:networks_sensors) do
      add :network_id, references(:networks, on_delete: :delete_all)
      add :sensor_id, references(:sensors, on_delete: :delete_all)
    end

    create unique_index(:networks_sensors, [:network_id, :sensor_id], name: :networks_sensors_uniq)
    create index(:networks_sensors, :network_id)
    create index(:networks_sensors, :sensor_id)
  end
end
