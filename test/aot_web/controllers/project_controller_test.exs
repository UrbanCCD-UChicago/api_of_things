defmodule AotWeb.ProjectControllerTest do
  use AotWeb.ConnCase, async: true

  describe "show" do
    @tag add2ctx: :projects
    test "an unknown slug will 404", %{conn: conn} do
      conn
      |> get(Routes.project_path(conn, :show, "nowhere"))
      |> json_response(:not_found)
    end
  end
end
