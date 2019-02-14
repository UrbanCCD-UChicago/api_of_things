defmodule Aot.Repo.Migrations.CreateSensors do
  use Ecto.Migration

  def change do
    create table(:sensors, primary_key: false) do
      add :path, :string, primary_key: true
      add :uom, :string, default: nil
      add :min, :float, default: nil
      add :max, :float, default: nil
      add :data_sheet, :string, default: nil
    end

    create unique_index :sensors, :path
  end
end
