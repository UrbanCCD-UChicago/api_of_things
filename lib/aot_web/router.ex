defmodule AotWeb.Router do
  use AotWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", AotWeb do
    get "/", DocsController, :show
    get "/docs", DocsController, :show
    get "/api", DocsController, :show
    get "/api/docs", DocsController, :show
  end

  scope "/api", AotWeb do
    pipe_through :api

    resources "/projects", ProjectController, only: [:index, :show]
    resources "/nodes", NodeController, only: [:index, :show]
    resources "/sensors", SensorController, only: [:index, :show]
    resources "/observations", ObservationController, only: [:index]
    resources "/raw-observations", RawObservationController, only: [:index]
  end
end
