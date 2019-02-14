defmodule AotWeb.ProjectController do
  @moduledoc ""

  use AotWeb, :controller
  import AotWeb.SharedPlugs
  import AotWeb.ControllerUtils, only: [build_meta: 3]
  alias Aot.Projects

  action_fallback AotWeb.FallbackController

  plug :order, default: "asc:name", fields: ~w(name)
  plug :paginate
  plug :format

  def index(conn, _params) do
    projects = Projects.list_projects()
    render conn, "index.json",
    projects: projects,
    format: conn.assigns[:format],
    meta: build_meta(&Routes.project_url/3, :index, conn)
  end

  def show(conn, %{"id" => id}) do
    with {:ok, project} <- Projects.get_project(id)
    do
      render(conn, "show.json", project: project, format: conn.assigns[:format])
    end
  end
end
