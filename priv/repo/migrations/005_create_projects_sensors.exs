defmodule Aot.Repo.Migrations.CreateProjectsSensors do
  use Ecto.Migration

  def change do
    create table(:projects_sensors) do
      add :project_slug, references(:projects, column: :slug, type: :text, on_delete: :delete_all)
      add :sensor_path, references(:sensors, column: :path, type: :text, on_delete: :delete_all)
    end

    create unique_index(:projects_sensors, [:project_slug, :sensor_path], name: :projects_sensors_uniq)
    create index(:projects_sensors, :project_slug)
    create index(:projects_sensors, :sensor_path)
  end
end
