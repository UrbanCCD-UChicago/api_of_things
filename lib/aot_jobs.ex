defmodule AotJobs do
  @moduledoc """
  """

  alias Aot.Projects

  alias AotJobs.{DBManager, Importer}

  @doc """
  """
  @spec import_projects() :: :ok
  def import_projects do
    Projects.list_projects()
    |> Enum.each(&Importer.import/1)
  end

  @doc """
  """
  @spec delete_old_data(binary()) :: :ok
  def delete_old_data(interval \\ "7 days") do
    DBManager.delete_old_observations(interval)
  end
end
