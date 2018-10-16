defmodule AotJobs do
  @moduledoc """
  """

  alias Aot.NetworkActions

  alias AotJobs.{DBManager, Importer}

  @doc """
  """
  @spec import_networks() :: :ok
  def import_networks do
    NetworkActions.list()
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
