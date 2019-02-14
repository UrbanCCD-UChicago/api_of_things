defmodule Aot.Repo.Migrations.CreateObservations do
  use Ecto.Migration

  def change do
    create table(:observations, primary_key: false) do
      add :node_vsn, references(:nodes, column: :vsn, type: :text, on_delete: :delete_all)
      add :sensor_path, references(:sensors, column: :path, type: :text, on_delete: :delete_all)
      add :timestamp, :naive_datetime, null: false
      add :value, :float, null: false
      add :location, :geometry
      add :uom, :string
    end

    execute """
    SELECT create_hypertable('observations', 'timestamp', chunk_time_interval => interval '1 day')
    """

    create unique_index :observations, [:node_vsn, :sensor_path, :timestamp], name: "obs_uniq"

    create index :observations, :node_vsn

    create index :observations, :sensor_path

    create index :observations, :timestamp

    create index :observations, :value

    create index :observations, :location, using: "gist"

    execute """
    CREATE MATERIALIZED VIEW latest_observations AS
      SELECT node_vsn, sensor_path, timestamp, value, location, uom
      FROM (
        SELECT node_vsn, sensor_path, timestamp, value, location, uom,
          row_number() OVER (
            PARTITION BY node_vsn, sensor_path
            ORDER BY timestamp DESC
          ) AS rownum
        FROM observations
      ) x
      WHERE rownum = 1
    """

    execute """
    CREATE MATERIALIZED VIEW node_sensors AS
      SELECT DISTINCT node_vsn, sensor_path
      FROM observations
    """
  end
end
