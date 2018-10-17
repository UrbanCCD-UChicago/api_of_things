defmodule Aot.Repo.Migrations.CreateProjectsNodes do
  use Ecto.Migration

  def change do
    create table(:projects_nodes) do
      add :project_slug, references(:projects, column: :slug, type: :text, on_delete: :delete_all)
      add :node_vsn, references(:nodes, column: :vsn, type: :text, on_delete: :delete_all)
    end

    create unique_index(:projects_nodes, [:project_slug, :node_vsn], name: :projects_nodes_uniq)
    create index(:projects_nodes, :project_slug)
    create index(:projects_nodes, :node_vsn)
  end
end
