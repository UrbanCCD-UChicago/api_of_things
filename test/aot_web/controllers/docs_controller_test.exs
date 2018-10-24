defmodule AotWeb.Testing.DocsControllerTest do
  use Aot.Testing.BaseCase
  use AotWeb.Testing.ConnCase

  describe "apiary redirect" do
    test "/", %{conn: conn} do
      conn
      |> get("/")
      |> html_response(:found)
    end

    test "/docs", %{conn: conn} do
      conn
      |> get("/docs")
      |> html_response(:found)
    end
  end

  describe "json links" do
    test "/api", %{conn: conn} do
      conn
      |> get("/api")
      |> json_response(:ok)
    end

    test "/api/docs", %{conn: conn} do
      conn
      |> get("/api/docs")
      |> json_response(:ok)
    end
  end
end
