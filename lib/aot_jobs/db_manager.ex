defmodule AotJobs.DBManager do
  @moduledoc ""

  alias Aot.Repo

  @doc false
  def delete_old_observations do
    Repo.query! "SELECT drop_chunks(interval '7 days', table_name => 'observations')"
  end
end
