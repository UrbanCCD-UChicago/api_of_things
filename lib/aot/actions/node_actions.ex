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

  @type ok_node :: {:ok, Aot.Node.t()} | {:error, Ecto.Changeset.t()}

  @doc """
  Creates a new Node.
  """
  @spec create(keyword() | map()) :: ok_node
  def create(params) do
    params = atomize(params)

    Node.changeset(%Node{}, params)
    |> Repo.insert()
  end

  @doc """
  Updates an existing Node.
  """
  @spec update(Node.t(), keyword() | map()) :: ok_node
  def update(node, params) do
    params = atomize(params)

    Node.changeset(node, params)
    |> Repo.update()
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
