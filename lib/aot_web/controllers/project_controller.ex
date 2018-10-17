defmodule AotWeb.ProjectController do
  use AotWeb, :controller

  import AotWeb.ControllerUtils, only: [
    resp_format: 1
  ]

  import AotWeb.GenericPlugs

  import AotWeb.ProjectPlugs

  alias Aot.ProjectActions

  action_fallback AotWeb.FallbackController

  plug :assign_if_exists, param: "include_nodes", value_override: true
  plug :assign_if_exists, param: "include_sensors", value_override: true
  plug :assign_if_exists, param: "has_node"
  plug :assign_if_exists, param: "has_nodes"
  plug :assign_if_exists, param: "has_nodes_exact"
  plug :assign_if_exists, param: "has_sensor"
  plug :assign_if_exists, param: "has_sensors"
  plug :assign_if_exists, param: "has_sensors_exact"
  plug :bbox
  plug :order, default: "asc:name", fields: ~W(name slug)
  plug :paginate

  def index(conn, _params) do
    projects = ProjectActions.list(Map.to_list(conn.assigns))
    fmt = resp_format(conn)

    render conn, "index.json",
      projects: projects,
      resp_format: fmt
  end

  def show(conn, %{"id" => slug}) do
    with {:ok, project} <- ProjectActions.get(slug, Map.to_list(conn.assigns))
    do
      render conn, "show.json",
        project: project,
        resp_format: resp_format(conn)
    end
  end
end
