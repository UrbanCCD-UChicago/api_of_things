defmodule Aot.Repo.Migrations.CreateNetworksSensors do
  use Ecto.Migration

  def change do
    create table(:networks_sensors) do
      add :network_slug, references(:networks, column: :slug, type: :text, on_delete: :delete_all)
      add :sensor_path, references(:sensors, column: :path, type: :text, on_delete: :delete_all)
    end

    create unique_index(:networks_sensors, [:network_slug, :sensor_path], name: :networks_sensors_uniq)
    create index(:networks_sensors, :network_slug)
    create index(:networks_sensors, :sensor_path)
  end
end
