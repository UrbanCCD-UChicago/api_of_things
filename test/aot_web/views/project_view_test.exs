defmodule AotWeb.ProjectViewTest do
  use AotWeb.ConnCase, async: true

  @tag add2ctx: :projects
  test "json view", %{conn: conn, chicago: project} do
    %{"data" => data} =
        conn
        |> get(Routes.project_path(conn, :show, project))
        |> json_response(:ok)

      assert is_map(data)
      assert Map.has_key?(data, "name")
      assert Map.has_key?(data, "slug")
      assert Map.has_key?(data, "hull")
  end

  @tag add2ctx: :projects
  test "geojson view", %{conn: conn, chicago: project} do
    %{"data" => data} =
        conn
        |> get(Routes.project_path(conn, :show, project, format: "geojson"))
        |> json_response(:ok)

      assert is_map(data)
      assert Map.has_key?(data, "type")
      assert Map.has_key?(data, "geometry")
      assert Map.has_key?(data, "properties")

      props = data["properties"]
      assert Map.has_key?(props, "name")
      assert Map.has_key?(props, "slug")
  end
end
