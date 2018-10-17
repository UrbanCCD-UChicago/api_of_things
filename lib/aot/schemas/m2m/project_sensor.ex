defmodule Aot.ProjectSensor do
  use Ecto.Schema
  import Ecto.Changeset

  schema "projects_sensors" do
    belongs_to :project, Aot.Project,
      foreign_key: :project_slug,
      references: :slug,
      type: :string

    belongs_to :sensor, Aot.Sensor,
      foreign_key: :sensor_path,
      references: :path,
      type: :string
  end

  @doc false
  def changeset(project_sensor, attrs) do
    project_sensor
    |> cast(attrs, [:project_slug, :sensor_path])
    |> validate_required([:project_slug, :sensor_path])
    |> foreign_key_constraint(:project_slug)
    |> foreign_key_constraint(:sensor_path)
    |> unique_constraint(:project_slug, name: :projects_sensors_uniq)
  end
end
