defmodule Aot.Repo.Migrations.CreateObservations do
  use Ecto.Migration

  def change do
    create table(:observations) do
      add :node_id, references(:nodes, type: :text, on_delete: :restrict)
      add :sensor_id, references(:sensors, on_delete: :restrict)
      add :timestamp, :naive_datetime
      add :value, :float
    end

    execute """
    SELECT create_hypertable('observations', 'timestamp', chunk_time_interval => interval '1 day')
    """

    create unique_index(:observations, [:node_id, :sensor_id, :timestamp])
    create index(:observations, :node_id)
    create index(:observations, :sensor_id)
    create index(:observations, :timestamp)
    create index(:observations, :value)
  end
end
