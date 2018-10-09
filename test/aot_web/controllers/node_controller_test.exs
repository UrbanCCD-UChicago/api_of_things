defmodule AotWeb.Testing.NodeControllerTest do
  use Aot.Testing.BaseCase
  use AotWeb.Testing.ConnCase

  describe "index" do
    test "using no filters should return all nodes", %{conn: conn} do
      resp =
        conn
        |> get(node_path(conn, :index))
        |> json_response(:ok)

      assert length(resp["data"]) == 6
    end

    test "using `include_networks` should embed the related networks", %{conn: conn} do
      resp =
        conn
        |> get(node_path(conn, :index))
        |> json_response(:ok)

      resp["data"]
      |> Enum.each(& assert &1["networks"] == [])

      resp =
        conn
        |> get(node_path(conn, :index, include_networks: "true"))
        |> json_response(:ok)

      resp["data"]
      |> Enum.each(& refute &1["networks"] == [])
    end

    test "using `include_sensors` should embed the related sensors", %{conn: conn} do
      # resp =
      #   conn
      #   |> get(node_path(conn, :index))
      #   |> json_response(:ok)

      # resp["data"]
      # |> Enum.each(& assert &1["sensors"] == [])

      resp =
        conn
        |> get(node_path(conn, :index, include_sensors: "true"))
        |> json_response(:ok)

      resp["data"]
      |> Enum.each(& refute &1["sensors"] == [])
    end

    test "using `only_alive` should filter the list to only nodes who are still alive", %{conn: conn} do
      resp =
        conn
        |> get(node_path(conn, :index, only_alive: "true"))
        |> json_response(:ok)

      assert length(resp["data"]) == 5
    end

    test "using `only_dead` should filter the list to only nodes who are dead", %{conn: conn} do
      resp =
        conn
        |> get(node_path(conn, :index, only_dead: "true"))
        |> json_response(:ok)

      assert length(resp["data"]) == 1
    end

    @tag add2ctx: :networks
    test "using `within_network` should filter the list to only nodes in the given network", %{conn: conn, denver: denver} do
      resp =
        conn
        |> get(node_path(conn, :index, within_network: denver.slug))
        |> json_response(:ok)

      assert length(resp["data"]) == 1
    end

    @tag add2ctx: :networks
    test "using `within_networks[]` should filter the list to only nodes in the given networks", %{conn: conn, chicago_complete: chic, chicago_public: chip} do
      resp =
        conn
        |> get(node_path(conn, :index, "within_networks[]": [chic.slug, chip.slug]))
        |> json_response(:ok)

      assert length(resp["data"]) == 6
    end

    @tag add2ctx: :sensors
    test "using `has_sensor` should filter the list to only nodes that have the given sensor", %{conn: conn, s13: s13} do
      resp =
        conn
        |> get(node_path(conn, :index, has_sensor: s13.path))
        |> json_response(:ok)

      assert length(resp["data"]) == 5
    end

    @tag add2ctx: :sensors
    test "using `has_sensors[]` should filter the list to only nodes that have the given sensors", %{conn: conn, s13: s13, s12: s12} do
      resp =
        conn
        |> get(node_path(conn, :index, "has_sensors[]": [s13.path, s12.path]))
        |> json_response(:ok)

      assert length(resp["data"]) == 6
    end

    test "using `location=within:x` should filter the list to nodes located within the polygon", %{conn: conn} do
      resp =
        conn
        |> get(node_path(conn, :index))
        |> json_response(:ok)
    end

    test "using `location=proximity:n,x` should filter the list to nodes located within N meters of location X", %{conn: conn} do
      resp =
        conn
        |> get(node_path(conn, :index))
        |> json_response(:ok)
    end

    test "using `commissioned_on=lt:x` should filter the nodes to those brought online before X", %{conn: conn} do
      resp =
        conn
        |> get(node_path(conn, :index))
        |> json_response(:ok)
    end

    test "using `commissioned_on=le:x` should filter the nodes to those brought online before or on X", %{conn: conn} do
      resp =
        conn
        |> get(node_path(conn, :index))
        |> json_response(:ok)
    end

    test "using `commissioned_on=eq:x` should filter the nodes to those brought online on X", %{conn: conn} do
      resp =
        conn
        |> get(node_path(conn, :index))
        |> json_response(:ok)
    end

    test "using `commissioned_on=ge:x` should filter the nodes to those brought online on or after X", %{conn: conn} do
      resp =
        conn
        |> get(node_path(conn, :index))
        |> json_response(:ok)
    end

    test "using `commissioned_on=gt:x` should filter the nodes to those brought online after X", %{conn: conn} do
      resp =
        conn
        |> get(node_path(conn, :index))
        |> json_response(:ok)
    end

    test "using `decommissioned_on=lt:x` should filter the nodes to those taken offline before X", %{conn: conn} do
      resp =
        conn
        |> get(node_path(conn, :index))
        |> json_response(:ok)
    end

    test "using `decommissioned_on=le:x` should filter the nodes to those taken offline before or on X", %{conn: conn} do
      resp =
        conn
        |> get(node_path(conn, :index))
        |> json_response(:ok)
    end

    test "using `decommissioned_on=eq:x` should filter the nodes to those taken offline on X", %{conn: conn} do
      resp =
        conn
        |> get(node_path(conn, :index))
        |> json_response(:ok)
    end

    test "using `decommissioned_on=ge:x` should filter the nodes to those taken offline on or after X", %{conn: conn} do
      resp =
        conn
        |> get(node_path(conn, :index))
        |> json_response(:ok)
    end

    test "using `decommissioned_on=gt:x` should filter the nodes to those taken offline after X", %{conn: conn} do
      resp =
        conn
        |> get(node_path(conn, :index))
        |> json_response(:ok)
    end

    test "using `order_by` should set the order of the nodes returned", %{conn: conn} do
      resp =
        conn
        |> get(node_path(conn, :index))
        |> json_response(:ok)
    end

    test "using `page` and `size` should set the pagination of the nodes returned", %{conn: conn} do
      resp =
        conn
        |> get(node_path(conn, :index))
        |> json_response(:ok)
    end
  end

  describe "show" do
    @tag add2ctx: :nodes
    test "using a valid node id should return the node requested", %{conn: conn, n000: n000} do
      conn
      |> get(node_path(conn, :show, n000.id))
      |> json_response(:ok)
    end

    @tag add2ctx: :nodes
    test "using a valid node vsn should return the node requested", %{conn: conn, n000: n000} do
      conn
      |> get(node_path(conn, :show, n000.vsn))
      |> json_response(:ok)
    end

    test "using an unknown identifier should 404", %{conn: conn} do
      conn
      |> get(node_path(conn, :show, "blah"))
      |> json_response(:not_found)
    end
  end
end
