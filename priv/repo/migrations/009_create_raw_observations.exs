defmodule Aot.Repo.Migrations.CreateRawObservations do
  use Ecto.Migration

  def change do
    create table(:raw_observations, primary_key: false) do
      add :node_id, references(:nodes, column: :id, type: :text, on_delete: :delete_all)
      add :sensor_path, references(:sensors, column: :path, type: :text, on_delete: :delete_all)
      add :timestamp, :naive_datetime, null: false
      add :hrf, :float, default: nil
      add :raw, :float
    end

    execute """
    SELECT create_hypertable('raw_observations', 'timestamp', chunk_time_interval => interval '1 day')
    """

    create unique_index(:raw_observations, [:node_id, :sensor_path, :timestamp], name: "raw_obs_unique_id")
    create index(:raw_observations, :node_id)
    create index(:raw_observations, :sensor_path)
    create index(:raw_observations, :timestamp)
  end
end
