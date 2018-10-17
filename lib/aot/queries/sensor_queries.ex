defmodule Aot.SensorQueries do
  @moduledoc """
  """

  import Aot.QueryUtils, only: [
    boolean_compose: 4,
    filter_compose: 4
  ]

  import Ecto.Query

  alias Aot.{
    Project,
    ProjectSensor,
    Node,
    NodeSensor,
    Sensor,
    SensorQueries
  }

  # BASE QUERIES

  @spec list() :: Ecto.Queryable.t()
  def list,
    do: from sensor in Sensor

  @spec get(binary()) :: Ecto.Queryable.t()
  def get(path),
    do: from sensor in Sensor,
      where: sensor.path == ^path

  # BOOLEAN COMPOSE

  @spec include_projects(Ecto.Queryable.t()) :: Ecto.Queryable.t()
  def include_projects(query),
    do: from sensor in query,
      preload: [projects: :sensors]

  @spec include_nodes(Ecto.Queryable.t()) :: Ecto.Queryable.t()
  def include_nodes(query),
    do: from sensor in query,
      preload: [nodes: :sensors]

  # FILTER COMPOSE

  @spec ontology(Ecto.Queryable.t(), any()) :: Ecto.Queryable.t()
  def ontology(query, ontology) do
    padded = "%#{ontology}%"

    from sensor in query,
      where: fragment("? like ?", sensor.ontology, ^padded)
  end

  @spec observes_project(Ecto.Queryable.t(), binary() | Aot.Project.t()) :: Ecto.Queryable.t()
  def observes_project(query, %Project{slug: slug}),
    do: observes_project(query, slug)

  def observes_project(query, slug) when is_binary(slug),
    do: observes_projects(query, [slug])

  @spec observes_projects(Ecto.Queryable.t(), maybe_improper_list()) :: Ecto.Queryable.t()
  def observes_projects(query, projects) when is_list(projects) do
    slugs =
      projects
      |> Enum.map(fn net ->
        case net do
          %Project{} -> net.slug
          slug -> slug
        end
      end)

    from sensor in query,
      left_join: nes in ProjectSensor, as: :nes, on: nes.sensor_path == sensor.path,
      left_join: net in Project, as: :net, on: nes.project_slug == net.slug,
      where: net.slug in ^slugs,
      distinct: true
  end

  @spec observes_projects_exact(Ecto.Queryable.t(), maybe_improper_list()) :: Ecto.Queryable.t()
  def observes_projects_exact(query, projects) when is_list(projects) do
    slugs =
      projects
      |> Enum.map(fn net ->
        case net do
          %Project{} -> net.slug
          slug -> slug
        end
      end)

    from sensor in query,
      left_join: nes in ProjectSensor, as: :nes, on: nes.sensor_path == sensor.path,
      left_join: net in Project, as: :net, on: nes.project_slug == net.slug,
      group_by: sensor.path,
      having: fragment("array_agg(?) @> ?", net.slug, ^slugs)
  end

  @spec onboard_node(Ecto.Queryable.t(), binary() | Aot.Node.t()) :: Ecto.Queryable.t()
  def onboard_node(query, %Node{id: id}),
    do: onboard_node(query, id)

  def onboard_node(query, id) when is_binary(id),
    do: onboard_nodes(query, [id])

  @spec onboard_nodes(Ecto.Queryable.t(), maybe_improper_list()) :: Ecto.Queryable.t()
  def onboard_nodes(query, nodes) when is_list(nodes) do
    ids =
      nodes
      |> Enum.map(fn node ->
        case node do
          %Node{} -> node.id
          id -> id
        end
      end)

    from sensor in query,
      left_join: nos in NodeSensor, as: :nos, on: nos.sensor_path == sensor.path,
      left_join: node in Node, as: :node, on: nos.node_id == node.id,
      where: node.id in ^ids,
      distinct: true
  end

  @spec onboard_nodes_exact(Ecto.Queryable.t(), maybe_improper_list()) :: Ecto.Queryable.t()
  def onboard_nodes_exact(query, nodes) when is_list(nodes) do
    ids =
      nodes
      |> Enum.map(fn node ->
        case node do
          %Node{} -> node.id
          id -> id
        end
      end)

    from sensor in query,
      left_join: nos in NodeSensor, as: :nos, on: nos.sensor_path == sensor.path,
      left_join: node in Node, as: :node, on: nos.node_id == node.id,
      group_by: sensor.path,
      having: fragment("array_agg(?) @> ?", node.id, ^ids)
  end

  defdelegate order(query, args), to: Aot.QueryUtils
  defdelegate paginate(query, args), to: Aot.QueryUtils

  # OTHER ACTION HELPERS

  @spec handle_opts(Ecto.Queryable.t(), keyword()) :: Ecto.Queryable.t()
  def handle_opts(query, opts \\ []) do
    opts =
      [
        include_projects: false,
        include_nodes: false,
        ontology: :empty,
        observes_project: :empty,
        observes_projects: :empty,
        observes_projects_exact: :empty,
        onboard_node: :empty,
        onboard_nodes: :empty,
        onboard_nodes_exact: :empty,
        order: :empty,
        paginate: :empty
      ]
      |> Keyword.merge(opts)

    query
    |> boolean_compose(opts[:include_projects], SensorQueries, :include_projects)
    |> boolean_compose(opts[:include_nodes], SensorQueries, :include_nodes)
    |> filter_compose(opts[:ontology], SensorQueries, :ontology)
    |> filter_compose(opts[:observes_project], SensorQueries, :observes_project)
    |> filter_compose(opts[:observes_projects], SensorQueries, :observes_projects)
    |> filter_compose(opts[:observes_projects_exact], SensorQueries, :observes_projects_exact)
    |> filter_compose(opts[:onboard_node], SensorQueries, :onboard_node)
    |> filter_compose(opts[:onboard_nodes], SensorQueries, :onboard_nodes)
    |> filter_compose(opts[:onboard_nodes_exact], SensorQueries, :onboard_nodes_exact)
    |> filter_compose(opts[:order], SensorQueries, :order)
    |> filter_compose(opts[:paginate], SensorQueries, :paginate)
  end
end
