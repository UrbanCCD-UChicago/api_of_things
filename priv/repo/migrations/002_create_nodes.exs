defmodule Aot.Repo.Migrations.CreateNodes do
  use Ecto.Migration

  def change do
    create table(:nodes, primary_key: false) do
      add :vsn, :text, primary_key: true
      add :id, :text, null: false
      add :location, :geometry, null: false
      add :address, :text, default: nil
      add :description, :text, default: nil
      add :commissioned_on, :naive_datetime, null: false
      add :decommissioned_on, :naive_datetime, default: nil
    end

    create unique_index(:nodes, :id)
    create unique_index(:nodes, :vsn)
    create index(:nodes, :location, using: "gist")
  end
end
