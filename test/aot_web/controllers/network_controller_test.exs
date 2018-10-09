defmodule AotWeb.Testing.NetworkControllerTest do
  use Aot.Testing.BaseCase
  use AotWeb.Testing.ConnCase

  describe "index" do
    test "no filters should return them all", %{conn: conn} do
      resp =
        conn
        |> get(network_path(conn, :index))
        |> json_response(:ok)

      assert length(resp["data"]) == 3
    end

    # TODO: i don't like returning an empty list for non-loaded associations.
    # they should be scrubbed from the response object if not loaded.

    test "using `include_nodes` should embed related nodes", %{conn: conn} do
      # not specified? then empty array
      resp =
        conn
        |> get(network_path(conn, :index))
        |> json_response(:ok)

      resp["data"]
      |> Enum.each(& assert &1["nodes"] == [])

      resp =
        conn
        |> get(network_path(conn, :index, include_nodes: true))
        |> json_response(:ok)

      resp["data"]
      |> Enum.each(& refute &1["nodes"] == [])
    end

    test "using `include_sensors` should embed related sensors", %{conn: conn} do
      # not specified? then empty array
      resp =
        conn
        |> get(network_path(conn, :index))
        |> json_response(:ok)

      resp["data"]
      |> Enum.each(& assert &1["sensors"] == [])

      resp =
        conn
        |> get(network_path(conn, :index, include_sensors: true))
        |> json_response(:ok)

      resp["data"]
      |> Enum.each(& refute &1["sensors"] == [])
    end

    @tag add2ctx: :nodes
    test "using `has_node` should filter the nets", %{conn: conn, n000: n000} do
      resp =
        conn
        |> get(network_path(conn, :index, has_node: n000.id))
        |> json_response(:ok)

      assert length(resp["data"]) == 1
    end

    @tag add2ctx: :nodes
    test "using `has_nodes[]` should filter the nets", %{conn: conn, n000: n000, n004: n004} do
      resp =
        conn
        |> get(network_path(conn, :index, "has_nodes[]": [n000.id, n004.id]))
        |> json_response(:ok)

      assert length(resp["data"]) == 3
    end

    @tag add2ctx: :sensors
    test "using `has_sensor` should filter the nets", %{conn: conn, s1: s1} do
      resp =
        conn
        |> get(network_path(conn, :index, has_sensor: s1.id))
        |> json_response(:ok)

      assert length(resp["data"]) == 1
    end

    @tag add2ctx: :sensors
    test "using `has_sensors[]` should filter the nets", %{conn: conn, s1: s1, s13: s13} do
      resp =
        conn
        |> get(network_path(conn, :index, "has_sensors[]": [s1.id, s13.id]))
        |> json_response(:ok)

      assert length(resp["data"]) == 3
    end

    test "using `bbox=contains:` should filter the nets", %{conn: conn} do
      pt =
        %Geo.Point{srid: 4326, coordinates: {-87.6, 41.8}}
        |> Geo.JSON.encode!()
        |> Poison.encode!()

      resp =
        conn
        |> get(network_path(conn, :index, bbox: "contains:#{pt}"))
        |> json_response(:ok)

      assert length(resp["data"]) == 2
    end

    test "using `bbox=intersects:` should filter the nets", %{conn: conn} do
      poly =
        %Geo.Polygon{srid: 4326, coordinates: [[{1, 1}, {1, 2}, {2, 2}, {2, 1}, {1, 1}]]}
        |> Geo.JSON.encode!()
        |> Poison.encode!()

      resp =
        conn
        |> get(network_path(conn, :index, bbox: "intersects:#{poly}"))
        |> json_response(:ok)

      assert length(resp["data"]) == 0
    end

    test "using `order_by` should set the ordering of the nodes", %{conn: conn} do
      resp =
        conn
        |> get(network_path(conn, :index, order_by: "desc:id"))
        |> json_response(:ok)

      cnt = length(resp["data"])
      resp["data"]
      |> Enum.with_index(1)
      |> Enum.each(fn {net, idx} ->
        if (idx + 1) < cnt do
          assert net["id"] > Enum.at(resp["data"], idx + 1)["id"]
        end
      end)
    end

    test "using `page` and `size` should paginate the results", %{conn: conn} do
      resp =
        conn
        |> get(network_path(conn, :index, page: 1, size: 1))
        |> json_response(:ok)

      assert length(resp["data"]) == 1

      resp =
        conn
        |> get(network_path(conn, :index, page: 10, size: 1))
        |> json_response(:ok)

      assert length(resp["data"]) == 0
    end
  end

  describe "show" do
    @tag add2ctx: :networks
    test "using a known slug as the param", %{conn: conn, chicago_complete: chicago} do
      conn
      |> get(network_path(conn, :show, chicago))
      |> json_response(:ok)
    end

    @tag add2ctx: :networks
    test "using a known id", %{conn: conn, chicago_complete: chicago} do
      conn
      |> get(network_path(conn, :show, chicago.id))
      |> json_response(:ok)
    end

    test "using an unknown identifier should 404", %{conn: conn} do
      conn
      |> get(network_path(conn, :show, "i-dont-exist"))
      |> json_response(:not_found)
    end
  end
end
