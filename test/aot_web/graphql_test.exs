defmodule AotWeb.Testing.GraphqlTest do
  use Aot.Testing.BaseCase
  use Aot.Testing.DataCase
  use AotWeb.Testing.ConnCase

  test "filter projects with intersects polygon query", %{conn: conn} do
    query = 
      """
      {
        projects (intersects: {
          srid: 4326
          coordinates: [[
            [-99.14, 35.74],
            [-73.47, 35.74],
            [-73.47, 49.61],
            [-99.14, 49.61],
            [-99.14, 35.74]
          ]]
        }) {
          name
        }
      }
      """

    response = 
      conn
      |> get("/graphql?query=#{query}")
      |> json_response(:ok)

    [project | _] = response["data"]["projects"]

    assert(length(response["data"]["projects"]) == 1)
    assert(project["name"] == "Chicago")
  end

  test "filter projects with contains point query", %{conn: conn} do
    query = 
      """
      {
        projects (contains: {
          srid: 4326
          coordinates: [-87.81, 41.73]
        }) {
          name
        }
      }
      """

    response = 
      conn
      |> get("/graphql?query=#{query}")
      |> json_response(:ok)

    [project | _] = response["data"]["projects"]

    assert(length(response["data"]["projects"]) == 1)
    assert(project["name"] == "Chicago")
  end

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
          id
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
          id
        }
      }
      """

    response = 
      conn
      |> get("/graphql?query=#{query}")
      |> json_response(:ok)

    assert(length(response["data"]["nodes"]) == 0)
  end

  test "filter nodes by commission status query", %{conn: conn} do
    query = 
      """
      {
        nodes (commissioned_on: {lt: "2000-01-01 00:00:00"}) {
          id
        }
      }
      """

    response = 
      conn
      |> get("/graphql?query=#{query}")
      |> json_response(:ok)

    assert(length(response["data"]["nodes"]) == 0)
  end

  test "filter nodes by decommission status query", %{conn: conn} do
    query = 
      """
      {
        nodes (decommissioned_on: {lt: "2000-01-01 00:00:00"}) {
          id
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
          id
        }
      }
      """

    response = 
      conn
      |> get("/graphql?query=#{query}")
      |> json_response(:ok)

    assert(length(response["data"]["nodes"]) == 110)
  end

  test "filter nodes by alive statue query", %{conn: conn} do
    query = 
      """
      {
        nodes (alive: true) {
          id
        }
      }
      """

    response = 
      conn
      |> get("/graphql?query=#{query}")
      |> json_response(:ok)

    assert(length(response["data"]["nodes"]) == 5)
  end


  test "filter nodes by dead statue query", %{conn: conn} do
    query = 
      """
      {
        nodes (alive: false) {
          id
        }
      }
      """

    response = 
      conn
      |> get("/graphql?query=#{query}")
      |> json_response(:ok)

    assert(length(response["data"]["nodes"]) == 5)
  end
  
  test "filter sensor by string query of ontology", %{conn: conn} do
    query = 
      """
      {
        sensors (ontology: {like: "light"}) {
          ontology
        }
      }
      """

    response = 
      conn
      |> get("/graphql?query=#{query}")
      |> json_response(:ok)

    [sensor | _] = response["data"]["sensors"]

    assert(length(response["data"]["sensors"]) == 5)
    assert(sensor["ontology"] == "/sensing/physical/light")
  end
  
  test "filter sensor by crazy string query of ontology", %{conn: conn} do
    query = 
      """
      {
        sensors (ontology: {like: "asdfasdf"}) {
          ontology
        }
      }
      """

    response = 
      conn
      |> get("/graphql?query=#{query}")
      |> json_response(:ok)

    assert(length(response["data"]["sensors"]) == 0)
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

    assert(length(response["data"]["observations"]) == 1491)
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
