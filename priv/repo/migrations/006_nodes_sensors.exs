defmodule Aot.Repo.Migrations.CreateNodesSensors do
  use Ecto.Migration

  def change do
    create table(:nodes_sensors, primary_key: false) do
      add :node_id, references(:nodes, type: :text, on_delete: :restrict)
      add :sensor_id, references(:sensors, on_delete: :restrict)
    end

    create unique_index(:nodes_sensors, [:node_id, :sensor_id], name: :nodes_sensors_uniq)
    create index(:nodes_sensors, :node_id)
    create index(:nodes_sensors, :sensor_id)
  end
end
