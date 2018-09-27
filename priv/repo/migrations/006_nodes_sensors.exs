defmodule Aot.Repo.Migrations.CreateNodesSensors do
  use Ecto.Migration

  def change do
    create table(:nodes_sensors) do
      add :node_id, references(:nodes, on_delete: :restrict)
      add :sensor_id, references(:sensors, type: :text, on_delete: :restrict)
    end

    create unique_index(:nodes_sensors, [:node_id, :sensor_id])
    create index(:nodes_sensors, :node_id)
    create index(:nodes_sensors, :sensor_id)
  end
end
