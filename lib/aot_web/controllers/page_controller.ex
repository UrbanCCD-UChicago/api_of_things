defmodule AotWeb.PageController do
  use AotWeb, :controller

  @docs Application.get_env(:aot, :docs_url)

  def index(conn, _), do: render(conn, "index.html")

  def ws_demo(conn, _), do: render(conn, "ws_demo.html")

  def apiary(conn, _), do: redirect(conn, external: @docs)

  def api_root(conn, _) do
    body = %{
      docs: @docs,
      endpoints: %{
        projects: Routes.project_url(conn, :index),
        nodes: Routes.node_url(conn, :index),
        sensors: Routes.sensor_url(conn, :index),
        observations: Routes.observation_url(conn, :index),
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
