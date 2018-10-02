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

  @type ok_network :: {:ok, Aot.Network.t()} | {:error, Ecto.Changeset.t()}

  @doc """
  Creates a new Network.
  """
  @spec create(keyword() | map()) :: ok_network
  def create(params) do
    params = atomize(params)

    Network.changeset(%Network{}, params)
    |> Repo.insert()
  end

  @doc """
  Updates an existing Network.
  """
  @spec update(Network.t(), keyword() | map()) :: ok_network
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
  @spec get!(String.t() | integer(), keyword()) :: Network.t()
  def get!(id, opts \\ []) do
    NetworkQueries.get(id)
    |> NetworkQueries.handle_opts(opts)
    |> Repo.one!()
  end
end
