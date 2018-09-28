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

  @doc """
  Creates or updates a Network.
  """
  @spec upsert(map() | keyword()) :: {:ok, Network.t()} | {:error, Ecto.Changeset.t()}
  def upsert(params) do
    params =
      params
      |> atomize()

    Network.changeset(%Network{}, params)
    |> Repo.insert(on_conflict: :replace_all)
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
