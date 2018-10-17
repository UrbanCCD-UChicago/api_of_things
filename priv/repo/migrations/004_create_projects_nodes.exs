defmodule Aot.Repo.Migrations.CreateProjectsNodes do
  use Ecto.Migration

  def change do
    create table(:projects_nodes) do
      add :project_slug, references(:projects, column: :slug, type: :text, on_delete: :delete_all)
      add :node_id, references(:nodes, column: :id, type: :text, on_delete: :delete_all)
    end

    create unique_index(:projects_nodes, [:project_slug, :node_id], name: :projects_nodes_uniq)
    create index(:projects_nodes, :project_slug)
    create index(:projects_nodes, :node_id)
  end
end
