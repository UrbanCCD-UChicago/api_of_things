defmodule AotWeb.DocsController do
  use AotWeb, :controller

  import AotWeb.Router.Helpers

  @docs Application.get_env(:aot, :docs_url)

  def apiary(conn, _), do: redirect(conn, external: @docs)

  def json_links(conn, _) do
    body =
      %{
        docs: @docs,
        endpoints: %{
          projects: project_url(conn, :index),
          nodes: node_url(conn, :index),
          sensors: sensor_url(conn, :index),
          observations: observation_url(conn, :index),
          raw_observations: raw_observation_url(conn, :index)
        },
        clients: %{
          python: "https://github.com/UrbanCCD-UChicago/aot-client-py",
          javascript: "https://github.com/UrbanCCD-UChicago/aot-client-js",
          r: "https://github.com/UrbanCCD-UChicago/aot-client-r",
        }
      }
      |> Jason.encode!()

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, body)
  end
end
