defmodule AotWeb.Router do
  use AotWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug Hammer.Plug, rate_limit: {"api", 60_000, 1_000}, by: :ip  # 1k req per minute by ip
  end

  scope "/", AotWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/docs", PageController, :apiary
    get "/ws-demo", PageController, :ws_demo
  end

  scope "/api", AotWeb do
    pipe_through :api

    get "/", PageController, :api_root
    resources "/projects", ProjectController, only: [:index, :show]
    resources "/nodes", NodeController, only: [:index, :show]
    resources "/sensors", SensorController, only: [:index, :show]
    resources "/observations", ObservationController, only: [:index]
    resources "/metrics", MetricController, only: [:index]
  end

  scope "/graphql" do
    forward "/i", Absinthe.Plug.GraphiQL,
      schema: AotWeb.Schema

    forward "/", Absinthe.Plug,
      schema: AotWeb.Schema
  end
end
