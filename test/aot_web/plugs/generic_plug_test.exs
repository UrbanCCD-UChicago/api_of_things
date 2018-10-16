defmodule AotWeb.GenericPlugsTest do
  use Aot.Testing.BaseCase
  use Aot.Testing.DataCase
  use AotWeb.Testing.ConnCase

  describe "apply_if_exists" do
    test "when no param is found, nothing is assigned", %{conn: conn} do
      %{"data" => data} =
        conn
        |> get(network_path(conn, :index))
        |> json_response(:ok)

      data
      |> Enum.each(& refute Map.has_key?(&1, "nodes"))
    end

    @tag add2ctx: :nodes
    test "when param is found its value is assigned", %{conn: conn, n004: n004, n006: n006} do
      %{"data" => data} =
        conn
        |> get(network_path(conn, :index, has_nodes_exact: [n004.id, n006.id]))
        |> json_response(:ok)

      assert length(data) == 1
    end

    test "when `value_override` is set, that value is applied", %{conn: conn} do
      %{"data" => data} =
        conn
        |> get(network_path(conn, :index, include_sensors: "true"))
        |> json_response(:ok)

      data
      |> Enum.each(& assert Map.has_key?(&1, "sensors"))
    end
  end

  describe "order" do
    test "when given it will order the response objects", %{conn: conn} do
      %{"data" => data} =
        conn
        |> get(network_path(conn, :index, order: "desc:name"))
        |> json_response(:ok)

      len = length(data)
      data
      |> Enum.with_index(1)
      |> Enum.each(fn {obj, idx} ->
        if (idx + 1) < len do
          assert obj["name"] >= Enum.at(data, idx + 1)["name"]
        end
      end)
    end

    test "when given a bad direction it will 400", %{conn: conn} do
      conn
      |> get(network_path(conn, :index, order: "sideways:name"))
      |> json_response(:bad_request)
    end

    test "when given a bad field it will 422", %{conn: conn} do
      conn
      |> get(network_path(conn, :index, order: "desc:barf"))
      |> json_response(:unprocessable_entity)
    end
  end

  describe "paginate" do
    test "when page is less than 0 it will 422", %{conn: conn} do
      conn
      |> get(network_path(conn, :index, page: -1))
      |> json_response(:unprocessable_entity)
    end

    test "when page is not an integer 400", %{conn: conn} do
      conn
      |> get(network_path(conn, :index, page: "one"))
      |> json_response(:bad_request)
    end

    test "when size is less than 1 it will 422", %{conn: conn} do
      conn
      |> get(network_path(conn, :index, size: 0))
      |> json_response(:unprocessable_entity)
    end

    test "when size is greater than 5000 it will 422", %{conn: conn} do
      conn
      |> get(network_path(conn, :index, size: 5001))
      |> json_response(:unprocessable_entity)
    end

    test "when size is not an integer it will 400", %{conn: conn} do
      conn
      |> get(network_path(conn, :index, size: "ten"))
      |> json_response(:bad_request)
    end
  end
end
