defmodule Aot.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      # Start the Ecto repository
      supervisor(Aot.Repo, []),
      # Start the endpoint when the application starts
      supervisor(AotWeb.Endpoint, [])
    ]

    opts = [strategy: :one_for_one, name: Aot.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    AotWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
