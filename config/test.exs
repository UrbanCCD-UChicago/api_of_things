use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :aot, AotWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configures regularly scheduled jobs
config :aot, AotJobs.Scheduler,
  jobs: []

# Configures concurrency when loading data csv
config :aot, import_concurrency: [max_concurrency: 1, ordered: false]

# Configure your databases
config :aot, Aot.Repo, pool: Ecto.Adapters.SQL.Sandbox
