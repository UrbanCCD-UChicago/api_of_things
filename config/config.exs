use Mix.Config

# Configures the Ecto Repos
config :aot, Aot.Repo,
  username: "postgres",
  password: "password",
  database: "aot_#{Mix.env()}",
  hostname: "localhost",
  pool_size: 10,
  types: Aot.PostgresTypes

config :aot,
  ecto_repos: [Aot.Repo]

# Configures the endpoint
config :aot, AotWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "lqdfPEX7vYzmIMvbeHQrOJsURTaKtlcfLx4JegbAhh6TTOA6ykNQ/nhNMc1DC66k",
  render_errors: [view: AotWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: Aot.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id, :request_id]

# Configures regularly scheduled jobs
config :aot, AotJobs.Scheduler,
  jobs: [
    # every 5 minutes, pull in recent data from aot archives
    {"*/5 * * * *", {AotJobs, :import_projects, []}},

    # every day at 12:03 am, delete data older than 1 week
    {"3 0 * * *", {AotJobs, :delete_old_data, []}}
  ]

# Configures error reporting through Sentry
config :sentry,
  dsn: "https://public_key@app.getsentry.com/1",
  environment_name: Mix.env(),
  included_environments: [:prod]

# Configures concurrency when loading data csv
config :aot, import_concurrency: [max_concurrency: 8, ordered: false]

# Configures the redirect link to the apiary docs
config :aot, docs_url: "https://arrayofthings.docs.apiary.io/"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
