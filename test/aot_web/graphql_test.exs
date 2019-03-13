defmodule AotWeb.GraphqlTest do
  use AotWeb.ConnCase

  test "filter nodes within polygon query", %{conn: conn} do
    query =
      """
      {
        nodes (within: {
          srid: 4326
          coordinates: [[
            [-99.14, 35.74],
            [-73.47, 35.74],
            [-73.47, 49.61],
            [-99.14, 49.61],
            [-99.14, 35.74]
          ]]
        }) {
          vsn
        }
      }
      """

    response =
      conn
      |> get("/graphql?query=#{query}")
      |> json_response(:ok)

    assert(length(response["data"]["nodes"]) == 91)
  end

  test "filter nodes within crazy polygon query", %{conn: conn} do
    query =
      """
      {
        nodes (within: {
          srid: 4326
          coordinates: [[
            [0, 35.74],
            [10, 35.74],
            [10, 49.61],
            [0, 49.61],
            [0, 35.74]
          ]]
        }) {
          vsn
        }
      }
      """

    response =
      conn
      |> get("/graphql?query=#{query}")
      |> json_response(:ok)

    assert(length(response["data"]["nodes"]) == 0)
  end

  test "get all nodes", %{conn: conn} do
    query =
      """
      {
        nodes {
          vsn
        }
      }
      """

    response =
      conn
      |> get("/graphql?query=#{query}")
      |> json_response(:ok)

    assert(length(response["data"]["nodes"]) == 110)
  end

  test "filter observations within polygon query", %{conn: conn} do
    query =
      """
      {
        observations (within: {
          srid: 4326
          coordinates: [[
            [-99.14, 35.74],
            [-73.47, 35.74],
            [-73.47, 49.61],
            [-99.14, 49.61],
            [-99.14, 35.74]
          ]]
        }) {
          value
        }
      }
      """

    response =
      conn
      |> get("/graphql?query=#{query}")
      |> json_response(:ok)

    assert(length(response["data"]["observations"]) == 1002)
  end

  test "filter observations within crazy polygon query", %{conn: conn} do
    query =
      """
      {
        observations (within: {
          srid: 4326
          coordinates: [[
            [0, 35.74],
            [1, 35.74],
            [1, 49.61],
            [0, 49.61],
            [0, 35.74]
          ]]
        }) {
          value
        }
      }
      """

    response =
      conn
      |> get("/graphql?query=#{query}")
      |> json_response(:ok)

    assert(length(response["data"]["observations"]) == 0)
  end
end
