defmodule Aot.Projects do
  @moduledoc ""

  import Ecto.Query, warn: false
  import Aot.QueryUtils
  alias Aot.Repo
  alias Aot.Projects.{Project, ProjectQueries}

  @doc ""
  def list_projects(opts \\ []) do
    opts = Keyword.merge([
      order: :empty,
      paginate: :empty
    ], opts)

    from(p in Project)
    |> filter_compose(opts[:order], ProjectQueries, :order)
    |> filter_compose(opts[:paginate], ProjectQueries, :paginate)
    |> Repo.all()
  end

  @doc ""
  def get_project(slug) do
    case Repo.get_by(Project, slug: slug) do
      nil -> {:error, :not_found}
      project -> {:ok, project}
    end
  end

  @doc ""
  def create_project(attrs \\ %{}) do
    %Project{}
    |> Project.changeset(attrs)
    |> Repo.insert()
  end

  @doc ""
  def update_project(%Project{} = project, attrs) do
    project
    |> Project.changeset(attrs)
    |> Repo.update()
  end
end
