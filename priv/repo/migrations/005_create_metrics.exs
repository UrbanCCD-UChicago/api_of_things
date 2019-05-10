defmodule Aot.Repo.Migrations.CreateMetrics do
  use Ecto.Migration

  def change do
    create table(:metrics, primary_key: false) do
      add :node_vsn, references(:nodes, column: :vsn, type: :text, on_delete: :delete_all)
      add :sensor_path, references(:sensors, column: :path, type: :text, on_delete: :delete_all)
      add :timestamp, :naive_datetime, null: false
      add :value, :float, null: false
      add :location, :geometry
      add :uom, :string
    end

    execute """
    SELECT create_hypertable('metrics', 'timestamp', chunk_time_interval => interval '1 day')
    """

    create unique_index :metrics, [:node_vsn, :sensor_path, :timestamp], name: "metrics_uniq"

    create index :metrics, :node_vsn

    create index :metrics, :sensor_path

    create index :metrics, :timestamp

    create index :metrics, :value

    create index :metrics, :location, using: "gist"

    execute """
    CREATE MATERIALIZED VIEW latest_metrics AS
      SELECT node_vsn, sensor_path, timestamp, value, location, uom
      FROM (
        SELECT node_vsn, sensor_path, timestamp, value, location, uom,
          row_number() OVER (
            PARTITION BY node_vsn, sensor_path
            ORDER BY timestamp DESC
          ) AS rownum
        FROM metrics
      ) x
      WHERE rownum = 1
    """
  end
end
