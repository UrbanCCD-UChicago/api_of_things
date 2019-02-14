defmodule Aot.Repo.Migrations.EnableExtensions do
  use Ecto.Migration

  def up do
    execute "CREATE EXTENSION IF NOT EXISTS postgis"

    execute "CREATE EXTENSION IF NOT EXISTS timescaledb"
  end
end
