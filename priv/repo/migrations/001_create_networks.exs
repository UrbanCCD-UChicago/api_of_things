defmodule Aot.Repo.Migrations.CreateNetworks do
  use Ecto.Migration

  def change do
    create table(:networks, primary_key: false) do
      add :name, :text, null: false
      add :slug, :text, primary_key: true
      add :bbox, :geometry, default: nil
      add :hull, :geometry, default: nil
      add :archive_url, :text, null: false
      add :recent_url, :text, null: false
      add :first_observation, :naive_datetime, default: nil
      add :latest_observation, :naive_datetime, default: nil
    end

    create unique_index(:networks, :name)
    create unique_index(:networks, :archive_url)
    create unique_index(:networks, :recent_url)
    create index(:networks, :bbox, using: "gist")
    create index(:networks, :hull, using: "gist")
  end
end
