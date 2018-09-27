defmodule Aot.Repo.Migrations.CreateRawObservations do
  use Ecto.Migration

  def change do
    create table(:raw_observations, primary_key: false) do
      add :node_id, references(:nodes, type: :text, on_delete: :restrict)
      add :sensor_id, references(:sensors, on_delete: :restrict)
      add :timestamp, :naive_datetime, null: false
      add :value, :float, null: false
    end

    execute """
    SELECT create_hypertable('raw_observations', 'timestamp', chunk_time_interval => interval '1 day')
    """

    create unique_index(:raw_observations, [:node_id, :sensor_id, :timestamp], name: "raw_obs_unique_id")
    create index(:raw_observations, :node_id)
    create index(:raw_observations, :sensor_id)
    create index(:raw_observations, :timestamp)
    create index(:raw_observations, :value)
  end
end
