defmodule AotWeb.Testing.NetworkControllerTest do
  use AotWeb.Testing.ConnCase

  alias Aot.{
    M2MActions,
    NetworkActions,
    NodeActions,
    SensorActions
  }

  setup do
    chi_poly = %Geo.Polygon{
      srid: 4326,
      coordinates: [[
        {-85, 40},
        {-85, 45},
        {-90, 45},
        {-90, 40},
        {-85, 40}
      ]]
    }

    denver_poly = %Geo.Polygon{
      srid: 4326,
      coordinates: [[
        {-100, 30},
        {-100, 32},
        {-102, 32},
        {-102, 30},
        {-100, 30}
      ]]
    }

    {:ok, chicago} =
      NetworkActions.create(
        name: "Chicago Complete",
        archive_url: "https://example.com/archive-chi",
        recent_url: "https://example.com/recent-chi",
        first_observation: ~N[2018-01-01 00:00:00],
        latest_observation: NaiveDateTime.utc_now(),
        bbox: chi_poly
      )

    {:ok, denver} =
      NetworkActions.create(
        name: "Denver Complete",
        archive_url: "https://example.com/archive-den",
        recent_url: "https://example.com/recent-den",
        first_observation: ~N[2018-06-01 00:00:00],
        latest_observation: NaiveDateTime.utc_now(),
        bbox: denver_poly
      )

    {:ok, chicago: chicago, denver: denver}
  end

  describe "index/2" do
    test "no filters should return them all", %{conn: conn, chicago: chi, denver: den} do
      resp =
        conn
        |> get(network_path(conn, :index))
        |> json_response(:ok)

      assert length(resp["data"]) == 2

      slugs = Enum.map(resp["data"], & &1["slug"])
      [chi.slug, den.slug]
      |> Enum.each(& assert Enum.member?(slugs, &1))
    end

    test "using `include_nodes` should embed related nodes", %{conn: conn, chicago: chicago} do
      # not specified? then empty array
      resp =
        conn
        |> get(network_path(conn, :index))
        |> json_response(:ok)

      resp["data"]
      |> Enum.each(& assert &1["nodes"] == [])

      # specified? embed the nodes
      {:ok, node} =
        NodeActions.create(
          id: "123ABC456DEF",
          vsn: "010",
          longitude: -87.1234,
          latitude: 43.4321,
          commissioned_on: NaiveDateTime.utc_now()
        )
      {:ok, _} = M2MActions.create_network_node(network: chicago, node: node)

      resp =
        conn
        |> get(network_path(conn, :index, include_nodes: true))
        |> json_response(:ok)

      chi_el = List.first(resp["data"])
      assert length(chi_el["nodes"]) == 1

      den_el = List.last(resp["data"])
      assert length(den_el["nodes"]) == 0
    end

    test "using `include_sensors` should embed related sensors", %{conn: conn} do
    end

    test "using `has_node` should filter the nets", %{conn: conn} do
    end

    test "using `has_nodes[]` should filter the nets", %{conn: conn} do
    end

    test "using `has_sensor` should filter the nets", %{conn: conn} do
    end

    test "using `has_sensors[]` should filter the nets", %{conn: conn} do
    end

    test "using `bbox=contains:` should filter the nets", %{conn: conn} do
    end

    test "using `bbox=intersects:` should filter the nets", %{conn: conn} do
    end

    test "using `order_by` should set the ordering of the nodes", %{conn: conn} do
    end

    test "using `page` and `size` should paginate the results", %{conn: conn} do
    end
  end

  describe "show/2" do
    test "using a known slug as the param", %{conn: conn, chicago: chicago} do
      conn
      |> get(network_path(conn, :show, chicago))
      |> json_response(:ok)
    end

    test "using a known id", %{conn: conn, chicago: chicago} do
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
