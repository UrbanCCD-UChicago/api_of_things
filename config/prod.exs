use Mix.Config

# configures the web endpoint
config :aot, AotWeb.Endpoint,
  http: [
    port: 8888
  ],
  url: [
    host: "api-of-things.plenar.io",
    port: 443,
    scheme: "https"
  ],
  cache_static_manifest: "priv/static/cache_manifest.json"

# Do not print debug messages in production
config :logger, level: :warn, metadata: [:request_id]

# ## Using releases
config :phoenix, :serve_endpoints, true

# Finally import the config/prod.secret.exs
# which should be versioned separately.
import_config "prod.secret.exs"
