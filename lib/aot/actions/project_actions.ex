defmodule Aot.ProjectActions do
  @moduledoc """
  The internal API for working with Projects.
  """

  import Aot.ActionUtils

  alias Aot.{
    Project,
    ProjectQueries,
    Repo
  }

  alias Ecto.Changeset

  # CRUD FUNCTIONS

  @doc """
  Creates a new Project.
  """
  @spec create(keyword() | map()) :: {:ok, Project.t()} | {:error, Changeset.t()}
  def create(params) do
    params = atomize(params)

    Project.changeset(%Project{}, params)
    |> Repo.insert()
  end

  @doc """
  Updates an existing Project.
  """
  @spec update(Project.t(), keyword() | map()) :: {:ok, Project.t()} | {:error, Changeset.t()}
  def update(project, params) do
    params = atomize(params)

    Project.changeset(project, params)
    |> Repo.update()
  end

  @doc """
  Gets a list of Projects and optionally augments the query.
  """
  @spec list(keyword()) :: list(Project.t())
  def list(opts \\ []) do
    ProjectQueries.list()
    |> ProjectQueries.handle_opts(opts)
    |> Repo.all()
  end

  @doc """
  Gets a single Project and optionally augments the query.
  """
  @spec get(String.t() | integer(), keyword()) :: {:ok, Project.t()} | {:error, :not_found}
  def get(slug, opts \\ []) do
    res =
      ProjectQueries.get(slug)
      |> ProjectQueries.handle_opts(opts)
      |> Repo.one()

    case res do
      nil -> {:error, :not_found}
      net -> {:ok, net}
    end
  end

  # UPDATE HELPERS

  @doc """
  Uses PostGIS functions to compute a bounding box from the
  related Nodes' locations.
  """
  @spec compute_bbox(Project.t() | integer()) :: Geo.Polygon.t()
  def compute_bbox(%Project{slug: slug}), do: compute_bbox(slug)
  def compute_bbox(slug) do
    ProjectQueries.compute_bbox(slug)
    |> Repo.one()
  end

  @doc """
  Uses PostGIS functions to compute a convex hull from the
  related Nodes' locations.
  """
  @spec compute_hull(Project.t() | integer()) :: Geo.Polygon.t()
  def compute_hull(%Project{slug: slug}), do: compute_hull(slug)
  def compute_hull(slug) do
    ProjectQueries.compute_hull(slug)
    |> Repo.one()
  end
end
