defmodule Aot.ProjectNode do
  use Ecto.Schema
  import Ecto.Changeset

  schema "projects_nodes" do
    belongs_to :project, Aot.Project,
      foreign_key: :project_slug,
      references: :slug,
      type: :string

    belongs_to :node, Aot.Node,
      foreign_key: :node_vsn,
      references: :vsn,
      type: :string
  end

  @params [:project_slug, :node_vsn]

  @doc false
  def changeset(project_node, attrs) do
    project_node
    |> cast(attrs, @params)
    |> validate_required(@params)
    |> foreign_key_constraint(:project_slug)
    |> foreign_key_constraint(:node_vsn)
    |> unique_constraint(:project_slug, name: :projects_nodes_uniq)
  end
end
