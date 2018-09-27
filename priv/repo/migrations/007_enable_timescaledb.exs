defmodule Aot.Repo.Migrations.EnableTimescaleDB do
  use Ecto.Migration

  def up do
    execute """
    CREATE EXTENSION IF NOT EXISTS timescaledb
    """
  end
end
