defmodule AotWeb.Testing.NodeControllerTest do
  use Aot.Testing.BaseCase
  use Aot.Testing.DataCase
  use AotWeb.Testing.ConnCase

  describe "index" do
    test "response data should be an array of objects", %{conn: conn} do
      %{"data" => data} =
        conn
        |> get(node_path(conn, :index))
        |> json_response(:ok)

      assert is_list(data)

      data
      |> Enum.each(& assert is_map(&1))
    end
  end

  describe "show" do
    @tag add2ctx: :nodes
    test "response data should be a single object", %{conn: conn, n004: node} do
      %{"data" => data} =
        conn
        |> get(node_path(conn, :show, node))
        |> json_response(:ok)

      assert is_map(data)
    end

    test "using an unknown id should 404", %{conn: conn} do
      conn
      |> get(node_path(conn, :show, "dunno"))
      |> json_response(:not_found)
    end
  end
end
