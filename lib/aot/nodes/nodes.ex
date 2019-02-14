defmodule Aot.Nodes do
  @moduledoc ""

  import Ecto.Query, warn: false
  import Aot.QueryUtils
  alias Aot.Nodes.NodeQueries
  alias Aot.Repo

  @doc ""
  def list_nodes(opts \\ []) do
    opts = Keyword.merge([
      with_sensors: false,
      for_project: :empty,
      located_within: :empty,
      located_dwithin: :empty,
      order: :empty,
      paginate: :empty
    ], opts)

    NodeQueries.list()
    |> bool_compose(opts[:with_sensors], NodeQueries, :with_sensors)
    |> filter_compose(opts[:for_project], NodeQueries, :for_project)
    |> filter_compose(opts[:located_within], NodeQueries, :located_within)
    |> filter_compose(opts[:located_dwithin], NodeQueries, :located_dwithin)
    |> filter_compose(opts[:order], NodeQueries, :order)
    |> filter_compose(opts[:paginate], NodeQueries, :paginate)
    |> Repo.all()
  end

  @doc ""
  def get_node(vsn, opts \\ []) do
    opts = Keyword.merge([
      with_sensors: false
    ], opts)

    node =
      NodeQueries.get(vsn)
      |> bool_compose(opts[:with_sensors], NodeQueries, :with_sensors)
      |> Repo.one()

    case node do
      nil -> {:error, :not_found}
      _ -> {:ok, node}
    end
  end
end
