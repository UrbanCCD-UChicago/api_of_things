defmodule Aot.Repo.Migrations.CreateNodes do
  use Ecto.Migration

  def change do
    create table(:nodes, primary_key: false) do
      add :vsn, :string, primary_key: true
      add :id, :string, null: false
      add :location, :geometry, null: false
      add :description, :string, default: nil
      add :address, :string, default: nil
    end

    create unique_index :nodes, :vsn

    create index :nodes, :location, using: "gist"

    create table(:project_nodes, primary_key: false) do
      add :project_slug, references(:projects, column: :slug, type: :text, on_delete: :restrict)
      add :node_vsn, references(:nodes, column: :vsn, type: :text, on_delete: :delete_all)
    end

    create unique_index :project_nodes, [:project_slug, :node_vsn]
  end
end
