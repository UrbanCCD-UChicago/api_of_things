defmodule Aot.NodeActions do
  @moduledoc """
  The internal API for working with Nodes.
  """

  import Aot.ActionUtils

  alias Aot.{
    Node,
    NodeQueries,
    Repo
  }

  @doc """
  Creates or updates a Node.
  """
  @spec upsert(map() | keyword()) :: {:ok, Node.t()} | {:error, Ecto.Changeset.t()}
  def upsert(params) do
    params =
      params
      |> atomize()

    Node.changeset(%Node{}, params)
    |> Repo.insert(on_conflict: :replace_all)
  end

  @doc """
  Gets a list of Nodes and optionally augments the query.
  """
  @spec list(keyword()) :: list(Node.t())
  def list(opts \\ []) do
    NodeQueries.list()
    |> NodeQueries.handle_opts(opts)
    |> Repo.all()
  end

  @doc """
  Gets a single Node and optionally augments the query.
  """
  @spec get!(String.t() | integer(), keyword()) :: Node.t()
  def get!(id, opts \\ []) do
    NodeQueries.get(id)
    |> NodeQueries.handle_opts(opts)
    |> Repo.one!()
  end
end
