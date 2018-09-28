defmodule Aot.Repo.Migrations.CreateNetworks do
  use Ecto.Migration

  def change do
    create table(:networks) do
      add :name, :text, null: false
      add :slug, :text, null: false
      add :bbox, :geometry, default: nil
      add :hull, :geometry, default: nil
      add :archive_url, :text, null: false
      add :recent_url, :text, null: false
      add :first_observation, :naive_datetime, null: false
      add :latest_observation, :naive_datetime, null: false
    end

    create unique_index(:networks, :name)
    create unique_index(:networks, :slug)
    create index(:networks, :bbox, using: "gist")
    create index(:networks, :hull, using: "gist")
  end
end
