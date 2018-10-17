defmodule Aot.ProjectNode do
  use Ecto.Schema
  import Ecto.Changeset

  schema "projects_nodes" do
    belongs_to :project, Aot.Project,
      foreign_key: :project_slug,
      references: :slug,
      type: :string

    belongs_to :node, Aot.Node,
      foreign_key: :node_id,
      references: :id,
      type: :string
  end

  @doc false
  def changeset(project_node, attrs) do
    project_node
    |> cast(attrs, [:project_slug, :node_id])
    |> validate_required([:project_slug, :node_id])
    |> foreign_key_constraint(:project_slug)
    |> foreign_key_constraint(:node_id)
    |> unique_constraint(:project_slug, name: :projects_nodes_uniq)
  end
end
