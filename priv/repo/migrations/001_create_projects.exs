defmodule Aot.Repo.Migrations.CreateProjects do
  use Ecto.Migration

  def change do
    create table(:projects, primary_key: false) do
      add :slug, :string, null: false, primary_key: true
      add :name, :string, null: false
      add :archive_url, :string, null: false
      add :recent_url, :string, null: false
      add :hull, :geometry, default: nil
    end

    create unique_index :projects, :name

    create unique_index :projects, :recent_url

    create unique_index :projects, :archive_url

    create index :projects, :hull, using: "gist"
  end
end
