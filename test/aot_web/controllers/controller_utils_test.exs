defmodule AotWeb.Testing.ControllerUtilsTest do
  use Aot.Testing.BaseCase
  use Aot.Testing.DataCase
  use AotWeb.Testing.ConnCase

  describe "format" do
    test "if no format is given, the response is regular JSON", %{conn: conn} do
      %{"data" => data} =
        conn
        |> get(project_path(conn, :index))
        |> json_response(:ok)

      assert is_list(data)

      data
      |> Enum.each(& assert is_map(&1))
    end

    test "if `geojson` is given, the response is that", %{conn: conn} do
      %{"data" => data} =
        conn
        |> get(project_path(conn, :index, format: "geojson"))
        |> json_response(:ok)

      assert is_list(data)

      data
      |> Enum.each(fn obj ->
        assert is_map(obj)
        assert Map.has_key?(obj, "type")
        assert Map.has_key?(obj, "geometry")
        assert Map.has_key?(obj, "properties")
      end)
    end
  end

  describe "meta" do
    test "adds `meta` object to response", %{conn: conn} do
      resp =
        conn
        |> get(observation_path(conn, :index))
        |> json_response(:ok)

      assert Map.has_key?(resp, "meta")
    end

    test "meta has `query` object", %{conn: conn} do
      resp =
        conn
        |> get(observation_path(conn, :index))
        |> json_response(:ok)

      meta = Map.get(resp, "meta")
      assert Map.has_key?(meta, "query")
    end

    test "query has all parsed parameters listed", %{conn: conn} do
      resp =
        conn
        |> get(observation_path(conn, :index))
        |> json_response(:ok)

      meta = Map.get(resp, "meta")
      query = Map.get(meta, "query")

      ["paginate", "order"]
      |> Enum.each(& assert Map.has_key?(query, &1))

      resp =
        conn
        |> get(observation_path(conn, :index, barf: true))
        |> json_response(:ok)

      meta = Map.get(resp, "meta")
      query = Map.get(meta, "query")

      ["paginate", "order"]
      |> Enum.each(& assert Map.has_key?(query, &1))
      refute Map.has_key?(query, "barf")

      resp =
        conn
        |> get(observation_path(conn, :index, embed_node: true))
        |> json_response(:ok)

      meta = Map.get(resp, "meta")
      query = Map.get(meta, "query")

      ["paginate", "order", "embed_node"]
      |> Enum.each(& assert Map.has_key?(query, &1))
    end

    test "meta has `links` object", %{conn: conn} do
      resp =
        conn
        |> get(observation_path(conn, :index))
        |> json_response(:ok)

      meta = Map.get(resp, "meta")
      assert Map.has_key?(meta, "links")
    end

    test "links has previous, current and next links", %{conn: conn} do
      resp =
        conn
        |> get(observation_path(conn, :index))
        |> json_response(:ok)

      meta = Map.get(resp, "meta")
      links = Map.get(meta, "links")

      ["previous", "current", "next"]
      |> Enum.each(& assert Map.has_key?(links, &1))
    end

    @tag add2ctx: :projects
    test "if call to :show, there is no metadata", %{conn: conn, chicago: chi} do
      resp =
        conn
        |> get(project_path(conn, :show, chi))
        |> json_response(:ok)

      refute Map.has_key?(resp, "meta")
    end

    test "if page is 1, previous link is null", %{conn: conn} do
      resp =
        conn
        |> get(observation_path(conn, :index))
        |> json_response(:ok)

      meta = Map.get(resp, "meta")
      links = Map.get(meta, "links")

      assert Map.has_key?(links, "previous") and Map.get(links, "previous") == nil

      resp =
        conn
        |> get(observation_path(conn, :index, page: 2))
        |> json_response(:ok)

      meta = Map.get(resp, "meta")
      links = Map.get(meta, "links")

      assert Map.has_key?(links, "previous") and Map.get(links, "previous") != nil
    end
  end
end
