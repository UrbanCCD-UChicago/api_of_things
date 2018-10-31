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
end
