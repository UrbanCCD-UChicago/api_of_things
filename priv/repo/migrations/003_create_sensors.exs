defmodule Aot.Repo.Migrations.CreateSensors do
  use Ecto.Migration

  def change do
    create table(:sensors, primary_key: false) do
      add :path, :text, primary_key: true
      add :ontology, :text, null: false
      add :subsystem, :text, null: false
      add :sensor, :text, null: false
      add :parameter, :text, null: false
      add :uom, :text, default: nil
      add :min, :float, default: nil
      add :max, :float, default: nil
      add :data_sheet, :text, default: nil
    end

    create index(:sensors, :ontology)
    create index(:sensors, :subsystem)
    create index(:sensors, :sensor)
    create index(:sensors, :parameter)
  end
end
