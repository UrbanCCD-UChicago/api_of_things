defmodule Aot.Projects.Project do
  @moduledoc ""

  use Ecto.Schema
  import Ecto.Changeset
  alias Ecto.Changeset

  @primary_key {:slug, :string, autogenerate: false}
  @derive {Phoenix.Param, key: :slug}
  schema "projects" do
    # field :slug, :string
    field :name, :string
    field :recent_url, :string
    field :archive_url, :string
    field :hull, Geo.PostGIS.Geometry, default: nil

    # relationships
    many_to_many :nodes, Aot.Nodes.Node,
      join_through: "project_nodes",
      join_keys: [project_slug: :slug, node_vsn: :vsn]
  end

  @attrs ~w| name recent_url archive_url hull |a
  @reqd ~w| name recent_url archive_url |a

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, @attrs)
    |> validate_required(@reqd)
    |> unique_constraint(:name)
    |> unique_constraint(:recent_url)
    |> unique_constraint(:archive_url)
    |> put_slug()
  end

  defp put_slug(%Changeset{valid?: true, changes: %{name: name}} = cs) do
    slug = SimpleSlug.slugify(name)
    put_change(cs, :slug, slug)
  end

  defp put_slug(cs), do: cs
end
