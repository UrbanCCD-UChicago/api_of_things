defmodule Aot.Repo.Migrations.CreateNodesSensors do
  use Ecto.Migration

  def change do
    create table(:nodes_sensors) do
      add :node_vsn, references(:nodes, column: :vsn, type: :text, type: :text, on_delete: :delete_all)
      add :sensor_path, references(:sensors, column: :path, type: :text, on_delete: :delete_all)
    end

    create unique_index(:nodes_sensors, [:node_vsn, :sensor_path], name: :nodes_sensors_uniq)
    create index(:nodes_sensors, :node_vsn)
    create index(:nodes_sensors, :sensor_path)
  end
end
