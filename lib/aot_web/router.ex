defmodule AotWeb.Router do
  use AotWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", AotWeb do
    pipe_through :api
  end
end
