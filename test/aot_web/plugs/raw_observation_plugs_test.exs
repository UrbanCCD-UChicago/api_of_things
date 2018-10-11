defmodule AotWeb.Testing.RawObservationPlugsTest do
  use Aot.Testing.BaseCase
  use Aot.Testing.DataCase
  use AotWeb.Testing.ConnCase

  describe "(compare) raw" do
    test "with a number", %{conn: conn} do
      conn
      |> get(raw_observation_path(conn, :index, raw: "lt:42"))
      |> json_response(:ok)
    end

    test "with a bad value will 400", %{conn: conn} do
      conn
      |> get(raw_observation_path(conn, :index, raw: "lt:barf"))
      |> json_response(:bad_request)
    end
  end

  describe "(compare) hrf" do
    test "with a number", %{conn: conn} do
      conn
      |> get(raw_observation_path(conn, :index, hrf: "lt:42"))
      |> json_response(:ok)
    end

    test "with a bad value will 400", %{conn: conn} do
      conn
      |> get(raw_observation_path(conn, :index, hrf: "barf:42"))
      |> json_response(:bad_request)
    end
  end

  describe "aggregates" do
    test "known function and grouper", %{conn: conn} do
      conn
      |> get(raw_observation_path(conn, :index, aggregates: "avg:node_id"))
      |> json_response(:ok)
    end

    test "with a bad function will 400", %{conn: conn} do
      conn
      |> get(raw_observation_path(conn, :index, aggregates: "average:node_id"))
      |> json_response(:bad_request)
    end

    test "with a bad grouper will 422", %{conn: conn} do
      conn
      |> get(raw_observation_path(conn, :index, aggregates: "avg:value"))
      |> json_response(:unprocessable_entity)
    end
  end

  describe "as_histograms" do
    test "with good args", %{conn: conn} do
      conn
      |> get(raw_observation_path(conn, :index, as_histograms: "1:2:3:4:5:node_id"))
      |> json_response(:ok)
    end

    test "with a bad number param will 400", %{conn: conn} do
      conn
      |> get(raw_observation_path(conn, :index, as_histograms: "one:2:3:4:5:node_id"))
      |> json_response(:bad_request)
    end

    test "with a bad grouping field will 422", %{conn: conn} do
      conn
      |> get(raw_observation_path(conn, :index, as_histograms: "1:2:3:4:5:value"))
      |> json_response(:unprocessable_entity)
    end
  end
end
