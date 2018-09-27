defmodule AotWeb.Router do
  use AotWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/api", AotWeb do
    pipe_through(:api)
    resources "/networks", NetworkController, only: [:index, :show]
    resources "/nodes", NodeController, only: [:index, :show]
    resources "/sensors", SensorController, only: [:index, :show]
    resources "/observations", ObservationController, only: [:index, :show]
    resources "/raw-observations", RawObservationController, only: [:index, :show]
  end
end
