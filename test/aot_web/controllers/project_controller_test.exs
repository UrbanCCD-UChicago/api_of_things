defmodule AotWeb.Testing.ProjectControllerTest do
  use Aot.Testing.BaseCase
  use Aot.Testing.DataCase
  use AotWeb.Testing.ConnCase

  describe "index" do
    test "response data should be an array of objects", %{conn: conn} do
      %{"data" => data} =
        conn
        |> get(project_path(conn, :index))
        |> json_response(:ok)

      assert is_list(data)

      data
      |> Enum.each(& assert is_map(&1))
    end
  end

  describe "show" do
    @tag add2ctx: :projects
    test "response data should be a single object", %{conn: conn, chicago: chicago} do
      %{"data" => data} =
        conn
        |> get(project_path(conn, :show, chicago))
        |> json_response(:ok)

      assert is_map(data)
    end

    test "using an unknown identifier should 404", %{conn: conn} do
      conn
      |> get(project_path(conn, :show, "i-dont-exist"))
      |> json_response(:not_found)
    end
  end
end
