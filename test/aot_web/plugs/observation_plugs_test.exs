defmodule AotWeb.Testing.ObservationPlugsTest do
  use Aot.Testing.BaseCase
  use Aot.Testing.DataCase
  use AotWeb.Testing.ConnCase

  describe "value=$COMP:" do
    test "with a number", %{conn: conn} do
      conn
      |> get(observation_path(conn, :index, value: "lt:42"))
      |> json_response(:ok)
    end

    test "with a bad value will 400", %{conn: conn} do
      conn
      |> get(observation_path(conn, :index, value: "lt:barf"))
      |> json_response(:bad_request)
    end
  end

  describe "value=$AGG" do
    test "known function and grouper", %{conn: conn} do
      conn
      |> get(observation_path(conn, :index, value: "avg:node_vsn"))
      |> json_response(:ok)
    end

    test "with a bad function", %{conn: conn} do
      conn
      |> get(observation_path(conn, :index, value: "average:node_vsn"))
      |> json_response(:bad_request)
    end

    test "with a bad grouper", %{conn: conn} do
      conn
      |> get(observation_path(conn, :index, value: "avg:value"))
      |> json_response(:unprocessable_entity)
    end
  end

  describe "as_histogram" do
    test "with good args", %{conn: conn} do
      conn
      |> get(observation_path(conn, :index, as_histogram: "1:2:3:node_vsn"))
      |> json_response(:ok)
    end

    test "with a bad number param", %{conn: conn} do
      conn
      |> get(observation_path(conn, :index, as_histogram: "1:2:three:node_vsn"))
      |> json_response(:bad_request)
    end

    test "with a bad grouping field", %{conn: conn} do
      conn
      |> get(observation_path(conn, :index, as_histogram: "1:2:3:value"))
      |> json_response(:unprocessable_entity)
    end
  end

  describe "as_time_buckets" do
    test "with good args", %{conn: conn} do
      conn
      |> get(observation_path(conn, :index, as_time_buckets: "avg:1 second"))
      |> json_response(:ok)
    end

    test "with a bad function param", %{conn: conn} do
      conn
      |> get(observation_path(conn, :index, as_time_buckets: "average:10 seconds"))
      |> json_response(:bad_request)
    end

    test "with a bad interval field", %{conn: conn} do
      conn
      |> get(observation_path(conn, :index, as_time_buckets: "avg:6 decades"))
      |> json_response(:bad_request)
    end
  end
end
