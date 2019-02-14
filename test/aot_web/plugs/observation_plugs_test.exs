defmodule AotWeb.ObservationPlugsTest do
  use AotWeb.ConnCase, async: true

  describe "timestamp" do
    test "lt", %{conn: conn} do
      %{"data" => data} =
        conn
        |> get(Routes.observation_path(conn, :index, timestamp: "lt:2018-04-21T15:00:00-06:00"))
        |> json_response(:ok)

      assert is_list(data)
      assert length(data) == 0
    end

    test "ge", %{conn: conn} do
      %{"data" => data} =
        conn
        |> get(Routes.observation_path(conn, :index, timestamp: "ge:2018-04-21T15:00:00-06:00", size: 5000))
        |> json_response(:ok)

      assert is_list(data)
      assert length(data) == 2952
    end

    test "between", %{conn: conn} do
      %{"data" => data} =
        conn
        |> get(Routes.observation_path(conn, :index, timestamp: "between:2018-04-21T15:00:00-06:00::2019-01-01T00:00:00-06:00"))
        |> json_response(:ok)

      assert is_list(data)
      assert length(data) == 200
    end
  end

  describe "value" do
    test "lt", %{conn: conn} do
      %{"data" => data} =
        conn
        |> get(Routes.observation_path(conn, :index, value: "lt:-10000"))
        |> json_response(:ok)

      assert is_list(data)
      assert length(data) == 0
    end

    test "ge", %{conn: conn} do
      %{"data" => data} =
        conn
        |> get(Routes.observation_path(conn, :index, value: "ge:-10000", size: 5000))
        |> json_response(:ok)

      assert is_list(data)
      assert length(data) == 2952
    end

    test "between", %{conn: conn} do
      %{"data" => data} =
        conn
        |> get(Routes.observation_path(conn, :index, value: "between:0::10000"))
        |> json_response(:ok)

      assert is_list(data)
      assert length(data) == 200
    end
  end

  test "histogram", %{conn: conn} do
    %{"data" => data} =
      conn
      |> get(Routes.observation_path(conn, :index, sensor: "metsense.bmp180.temperature", histogram: "-20::60::10"))
      |> json_response(:ok)

    assert is_list(data)
    assert length(data) == 42
  end

  describe "time_bucket" do
    test "min", %{conn: conn} do
      %{"data" => data} =
        conn
        |> get(Routes.observation_path(conn, :index,
          node: "064",
          sensor: "metsense.bmp180.temperature",
          time_bucket: "min:5 minutes",
          timestamp: "between:2018-10-15 20:30:00::2018-10-15 20:45:00")
        )
        |> json_response(:ok)

      assert is_list(data)
      Enum.each(data, fn obj ->
        assert is_map(obj)
        assert Map.has_key?(obj, "bucket")
        assert Map.has_key?(obj, "value")
      end)
    end

    test "max", %{conn: conn} do
      %{"data" => data} =
        conn
        |> get(Routes.observation_path(conn, :index,
          node: "064",
          sensor: "metsense.bmp180.temperature",
          time_bucket: "max:5 minutes",
          timestamp: "between:2018-10-15 20:30:00::2018-10-15 20:45:00")
        )
        |> json_response(:ok)

      assert is_list(data)
      Enum.each(data, fn obj ->
        assert is_map(obj)
        assert Map.has_key?(obj, "bucket")
        assert Map.has_key?(obj, "value")
      end)
    end

    test "avg", %{conn: conn} do
      %{"data" => data} =
        conn
        |> get(Routes.observation_path(conn, :index,
          node: "064",
          sensor: "metsense.bmp180.temperature",
          time_bucket: "avg:5 minutes",
          timestamp: "between:2018-10-15 20:30:00::2018-10-15 20:45:00")
        )
        |> json_response(:ok)

      assert is_list(data)
      Enum.each(data, fn obj ->
        assert is_map(obj)
        assert Map.has_key?(obj, "bucket")
        assert Map.has_key?(obj, "value")
      end)
    end

    test "median", %{conn: conn} do
      %{"data" => data} =
        conn
        |> get(Routes.observation_path(conn, :index,
          node: "064",
          sensor: "metsense.bmp180.temperature",
          time_bucket: "median:5 minutes",
          timestamp: "between:2018-10-15 20:30:00::2018-10-15 20:45:00")
        )
        |> json_response(:ok)

      assert is_list(data)
      Enum.each(data, fn obj ->
        assert is_map(obj)
        assert Map.has_key?(obj, "bucket")
        assert Map.has_key?(obj, "value")
      end)
    end
  end
end
