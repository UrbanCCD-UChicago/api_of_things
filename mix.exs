defmodule Aot.MixProject do
  use Mix.Project

  def project do
    [
      app: :aot,
      version: "2.4.0",
      elixir: "~> 1.8",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Aot.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(env) when env == :test or env == :travis, do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.4.0"},
      {:phoenix_pubsub, "~> 1.1"},
      {:phoenix_ecto, "~> 4.0"},
      {:ecto_sql, "~> 3.0"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},

      # database
      {:geo_postgis, "~> 2.1"},

      # utils
      {:simple_slug, "~> 0.1.1"},
      {:csv, "~> 2.1"},
      {:timex, "~> 3.4"},
      {:httpoison, "~> 1.3"},
      {:briefly, "~> 0.3.0"},
      {:nimble_csv, "~> 0.4.0"},
      {:quantum, "~> 2.3"},
      {:cors_plug, "~> 2.0"},

      # rate limiting
      {:hammer, "~> 6.0"},
      {:hammer_plug, "~> 2.0"},

      # graphql
      {:absinthe, "~> 1.4"},
      {:absinthe_plug, "~> 1.4"},
      {:dataloader, "~> 1.0.0"},

      # testing
      {:meck, "~> 0.8.13", override: true},
      {:mock, "~> 0.3.2", only: [:test, :travis]},

      # error reporting
      {:sentry, "~> 6.4"},

      # releases
      {:distillery, "~> 2.0"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.reset", "test"]
    ]
  end
end
