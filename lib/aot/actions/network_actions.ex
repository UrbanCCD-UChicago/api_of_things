defmodule Aot.NetworkActions do
  @moduledoc """
  The internal API for working with Networks.
  """

  import Aot.ActionUtils

  alias Aot.{
    Network,
    NetworkQueries,
    Repo
  }

  alias Ecto.Changeset

  # CRUD FUNCTIONS

  @doc """
  Creates a new Network.
  """
  @spec create(keyword() | map()) :: {:ok, Network.t()} | {:error, Changeset.t()}
  def create(params) do
    params = atomize(params)

    Network.changeset(%Network{}, params)
    |> Repo.insert()
  end

  @doc """
  Updates an existing Network.
  """
  @spec update(Network.t(), keyword() | map()) :: {:ok, Network.t()} | {:error, Changeset.t()}
  def update(network, params) do
    params = atomize(params)

    Network.changeset(network, params)
    |> Repo.update()
  end

  @doc """
  Gets a list of Networks and optionally augments the query.
  """
  @spec list(keyword()) :: list(Network.t())
  def list(opts \\ []) do
    NetworkQueries.list()
    |> NetworkQueries.handle_opts(opts)
    |> Repo.all()
  end

  @doc """
  Gets a single Network and optionally augments the query.
  """
  @spec get(String.t() | integer(), keyword()) :: {:ok, Network.t()} | {:error, :not_found}
  def get(id, opts \\ []) do
    resp =
      NetworkQueries.get(id)
      |> NetworkQueries.handle_opts(opts)
      |> Repo.one()

    case resp do
      nil -> {:error, :not_found}
      net -> {:ok, net}
    end
  end

  # UPDATE HELPERS

  @doc """
  Uses PostGIS functions to compute a bounding box from the
  related Nodes' locations.
  """
  @spec compute_bbox(Network.t() | integer()) :: Geo.Polygon.t()
  def compute_bbox(%Network{slug: slug}), do: compute_bbox(slug)
  def compute_bbox(slug) do
    poly =
      NetworkQueries.compute_bbox(slug)
      |> Repo.one()

    case poly do
      %Geo.Polygon{} -> poly
      _ -> nil
    end
  end

  @doc """
  Uses PostGIS functions to compute a convex hull from the
  related Nodes' locations.
  """
  @spec compute_hull(Network.t() | integer()) :: Geo.Polygon.t()
  def compute_hull(%Network{slug: slug}), do: compute_hull(slug)
  def compute_hull(slug) do
    poly =
      NetworkQueries.compute_hull(slug)
      |> Repo.one()

    case poly do
      %Geo.Polygon{} -> poly
      _ -> nil
    end
  end
end
