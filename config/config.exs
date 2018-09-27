use Mix.Config

# Configures the Ecto Repos
config :aot, Aot.Repo,
  adapter: Ecto.Adapters.Postgres,
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

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
