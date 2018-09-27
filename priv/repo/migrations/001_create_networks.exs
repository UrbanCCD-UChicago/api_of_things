defmodule Aot.MetaRepo.Migrations.CreateNetworks do
  use Ecto.Migration

  def change do
    create table(:networks) do
      add :name, :text
      add :slug, :text
      add :bbox, :geometry
      add :hull, :geometry
      add :num_observations, :integer
      add :num_raw_observations, :integer
    end

    create unique_index(:networks, :name)
    create unique_index(:networks, :slug)
    create index(:networks, :bbox, using: "gist")
    create index(:networks, :hull, using: "gist")
  end
end
