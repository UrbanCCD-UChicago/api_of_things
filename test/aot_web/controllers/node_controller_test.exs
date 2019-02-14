defmodule AotWeb.NodeControllerTest do
  use AotWeb.ConnCase, async: true

  describe "show" do
    @tag add2ctx: [:projects, :nodes]
    test "unknown vsn should return 404", %{conn: conn} do
      conn
      |> get(Routes.node_path(conn, :show, "dunno"))
      |> json_response(:not_found)
    end
  end
end
