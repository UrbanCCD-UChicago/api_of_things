defmodule Aot.Nodes.NodeQueries do
  @moduledoc ""

  import Ecto.Query
  import Geo.PostGIS, only: [st_contains: 2, st_dwithin_in_meters: 3]
  alias Aot.M2m.ProjectNode
  alias Aot.Nodes.Node
  alias Ecto.Queryable

  # bases

  @doc ""
  @spec list() :: Queryable.t()
  def list, do: from(n in Node)

  @doc ""
  @spec get(binary()) :: Queryable.t()
  def get(vsn), do: from(n in Node, where: n.vsn == ^vsn)

  # bool compose

  @doc ""
  @spec with_sensors(Queryable.t()) :: Queryable.t()
  def with_sensors(query), do: from n in query, preload: [sensors: :nodes]

  # filter compose

  @doc ""
  @spec for_project(Queryable.t(), binary()) :: Queryable.t()
  def for_project(query, slug) do
    from n in query,
      left_join: pn in ProjectNode, on: pn.node_vsn == n.vsn,
      where: pn.project_slug == ^slug,
      select: n
  end

  @doc ""
  @spec located_within(Queryable.t(), Geo.Polygon.t()) :: Queryable.t()
  def located_within(query, geom), do: from n in query, where: st_contains(^geom, n.location)

  @doc ""
  @spec located_dwithin(Queryable.t(), pos_integer(), Geo.Point.t()) :: Queryable.t()
  def located_dwithin(query, distance, geom), do: from n in query, where: st_dwithin_in_meters(n.location, ^geom, ^distance)

  defdelegate order(query, direction, field_name), to: Aot.QueryUtils
  defdelegate paginate(query, page_num, page_size), to: Aot.QueryUtils
end
