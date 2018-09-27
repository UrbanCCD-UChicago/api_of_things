defmodule Aot.MetaRepo.Migrations.EnablePostGIS do
  use Ecto.Migration

  def up do
    execute """
    CREATE EXTENSION IF NOT EXISTS postgis
    """
  end
end
