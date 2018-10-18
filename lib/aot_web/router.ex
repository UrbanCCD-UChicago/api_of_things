defmodule AotWeb.Router do
  use AotWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/api", AotWeb do
    pipe_through :api

    resources "/projects", ProjectController, only: [:index, :show]
    resources "/nodes", NodeController, only: [:index, :show]
    resources "/sensors", SensorController, only: [:index, :show]
    resources "/observations", ObservationController, only: [:index]
    resources "/raw-data", RawObservationController, only: [:index]
  end

  scope "/graphql" do
    forward "/i", Absinthe.Plug.GraphiQL,
      schema: AotWeb.Schema

    forward "/", Absinthe.Plug,
      schema: AotWeb.Schema
  end
end
