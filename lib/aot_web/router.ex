defmodule AotWeb.Router do
  use AotWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/api", AotWeb do
    pipe_through(:api)
    resources "/networks", NetworkController, except: [:new, :edit, :delete]
    resources "/nodes", NodeController, except: [:new, :edit, :delete]
  end
end
