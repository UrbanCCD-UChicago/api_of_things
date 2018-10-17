defmodule Aot.Repo.Migrations.CreateProjects do
  use Ecto.Migration

  def change do
    create table(:projects, primary_key: false) do
      add :name, :text, null: false
      add :slug, :text, primary_key: true
      add :bbox, :geometry, default: nil
      add :hull, :geometry, default: nil
      add :archive_url, :text, null: false
      add :recent_url, :text, null: false
      add :first_observation, :naive_datetime, default: nil
      add :latest_observation, :naive_datetime, default: nil
    end

    create unique_index(:projects, :name)
    create unique_index(:projects, :archive_url)
    create unique_index(:projects, :recent_url)
    create index(:projects, :bbox, using: "gist")
    create index(:projects, :hull, using: "gist")
  end
end
