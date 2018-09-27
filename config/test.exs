use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :aot, AotWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your databases
config :aot, Aot.MetaRepo, pool: Ecto.Adapters.SQL.Sandbox
config :aot, Aot.DataRepo, pool: Ecto.Adapters.SQL.Sandbox
