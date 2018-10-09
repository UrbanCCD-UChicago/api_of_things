defmodule Aot.Mixfile do
  use Mix.Project

  def project do
    [
      app: :aot,
      version: "0.0.1",
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
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
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
      {:postgrex, "~> 0.14.0-rc.0", override: true},
      {:geo_postgis, "~> 2.1"},

      # utils
      {:slugify, "~> 1.1"},
      {:csv, "~> 2.1"},
      {:timex, "~> 3.4"},
      {:jason, "~> 1.1"}
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
