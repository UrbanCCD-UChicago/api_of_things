defmodule Aot.Mixfile do
  use Mix.Project

  @version "0.3.2"

  def project do
    [
      app: :aot,
      version: @version,
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  def application do
    [
      mod: {Aot.Application, []},
      extra_applications: [:logger, :runtime_tools, :briefly, :sentry]
    ]
  end

  defp elixirc_paths(env) when env in [:test, :travis], do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      # phoenix deps
      {:phoenix, "~> 1.3.4"},
      {:phoenix_pubsub, "~> 1.0"},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 1.0"},

      # database deps
      {:ecto_sql, github: "elixir-ecto/ecto_sql", branch: "master"},
      {:postgrex, github: "elixir-ecto/postgrex", branch: "master", override: true},
      {:geo_postgis, "~> 2.1"},

      # utils
      {:slugify, "~> 1.1"},
      {:csv, "~> 2.1"},
      {:timex, "~> 3.4"},
      {:jason, "~> 1.1"},
      {:httpoison, "~> 1.3"},
      {:briefly, "~> 0.3.0"},
      {:nimble_csv, "~> 0.4.0"},
      {:quantum, "~> 2.3"},

      # testing
      {:mock, "~> 0.3.2", only: [:test, :travis]},

      # releases
      {:distillery, "~> 1.5"},
      {:sentry, "~> 6.4"}
    ]
  end

  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.drop --quiet", "ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
