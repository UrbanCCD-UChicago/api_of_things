defmodule AotJobs do
  @moduledoc """
  """

  alias Aot.ProjectActions

  alias AotJobs.{DBManager, Importer}

  @doc """
  """
  @spec import_projects() :: :ok
  def import_projects do
    ProjectActions.list()
    |> Enum.each(&Importer.import/1)
  end

  @doc """
  """
  @spec delete_old_data(binary()) :: :ok
  def delete_old_data(interval \\ "7 days") do
    DBManager.delete_old_observations(interval)
    DBManager.delete_old_raw_observations(interval)
  end
end
