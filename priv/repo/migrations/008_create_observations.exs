defmodule Aot.Repo.Migrations.CreateObservations do
  use Ecto.Migration

  def change do
    create table(:observations, primary_key: false) do
      add :node_vsn, references(:nodes, column: :vsn, type: :text, on_delete: :delete_all)
      add :sensor_path, references(:sensors, column: :path, type: :text, on_delete: :delete_all)
      add :timestamp, :naive_datetime, null: false
      add :value, :float, null: false
    end

    execute """
    SELECT create_hypertable('observations', 'timestamp', chunk_time_interval => interval '1 day')
    """

    create unique_index(:observations, [:node_vsn, :sensor_path, :timestamp], name: "obs_uniq")
    create index(:observations, :node_vsn)
    create index(:observations, :sensor_path)
    create index(:observations, :timestamp)
    create index(:observations, :value)
  end
end
