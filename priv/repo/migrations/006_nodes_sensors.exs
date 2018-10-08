defmodule Aot.Repo.Migrations.CreateNodesSensors do
  use Ecto.Migration

  def change do
    create table(:nodes_sensors) do
      add :node_id, references(:nodes, type: :text, on_delete: :delete_all)
      add :sensor_id, references(:sensors, on_delete: :delete_all)
    end

    create unique_index(:nodes_sensors, [:node_id, :sensor_id], name: :nodes_sensors_uniq)
    create index(:nodes_sensors, :node_id)
    create index(:nodes_sensors, :sensor_id)
  end
end
