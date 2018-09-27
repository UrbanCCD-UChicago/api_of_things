defmodule Aot.Repo.Migrations.CreateNetworks do
  use Ecto.Migration

  def change do
    create table(:networks) do
      add :name, :text, null: false
      add :slug, :text, null: false
      add :bbox, :geometry, default: nil
      add :hull, :geometry, default: nil
      add :num_observations, :integer, default: 0
      add :num_raw_observations, :integer, default: 0
    end

    create unique_index(:networks, :name)
    create unique_index(:networks, :slug)
    create index(:networks, :bbox, using: "gist")
    create index(:networks, :hull, using: "gist")
  end
end
