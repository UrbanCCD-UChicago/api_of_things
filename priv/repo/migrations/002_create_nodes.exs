defmodule Aot.Repo.Migrations.CreateNodes do
  use Ecto.Migration

  def change do
    create table(:nodes) do
      add :id, :text
      add :vsn, :text
      add :location, :geometry
      add :human_address, :text
      add :description, :text
      add :commissioned_on, :naive_datetime
      add :decommissioned_on, :naive_datetime
    end

    create unique_index(:nodes, :id)
    create unique_index(:nodes, :vsn)
    create index(:nodes, :location, using: "gist")
  end
end
