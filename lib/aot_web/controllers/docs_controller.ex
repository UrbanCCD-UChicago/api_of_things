defmodule AotWeb.DocsController do
  use AotWeb, :controller

  @docs Application.get_env(:aot, :docs_url)

  def show(conn, _), do: redirect(conn, external: @docs)
end
