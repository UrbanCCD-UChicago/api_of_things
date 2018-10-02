defmodule Aot.Repo.Migrations.CreateSensors do
  use Ecto.Migration

  def change do
    create table(:sensors) do
      add :ontology, :text, null: false
      add :subsystem, :text, null: false
      add :sensor, :text, null: false
      add :parameter, :text, null: false
      add :path, :text, null: false
      add :unit, :text, default: nil
      add :min_val, :float, default: nil
      add :max_val, :float, default: nil
    end

    create unique_index(:sensors, [:subsystem, :sensor, :parameter], name: :sensors_ssp)
    create index(:sensors, :ontology)
    create index(:sensors, :subsystem)
    create index(:sensors, :sensor)
    create index(:sensors, :parameter)
    create index(:sensors, :path)
  end
end
