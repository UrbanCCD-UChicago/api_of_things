defmodule Aot.MetaRepo.Migrations.CreateSensors do
  use Ecto.Migration

  def change do
    create table(:sensors) do
      add :ontology, :text
      add :subsystem, :text
      add :sensor, :text
      add :parameter, :text
      add :unit, :text
      add :min_val, :float
      add :max_val, :float
    end

    create unique_index(:sensors, [:subsystem, :sensor, :parameter])
    create index(:sensors, :ontology)
    create index(:sensors, :subsystem)
    create index(:sensors, :sensor)
    create index(:sensors, :parameter)
  end
end
