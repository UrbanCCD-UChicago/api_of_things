defmodule Aot.SensorActions do
  @moduledoc """
  The internal API for working with Sensors.
  """

  import Aot.ActionUtils

  alias Aot.{
    Sensor,
    SensorQueries,
    Repo
  }

  @doc """
  Creates or updates a Sensor.
  """
  @spec upsert(map() | keyword()) :: {:ok, Sensor.t()} | {:error, Ecto.Changeset.t()}
  def upsert(params) do
    params =
      params
      |> atomize()

    Sensor.changeset(%Sensor{}, params)
    |> Repo.insert(on_conflict: :replace_all)
  end

  @doc """
  Gets a list of Sensors and optionally augments the query.
  """
  @spec list(keyword()) :: list(Sensor.t())
  def list(opts \\ []) do
    SensorQueries.list()
    |> SensorQueries.handle_opts(opts)
    |> Repo.all()
  end

  @doc """
  Gets a single Sensor and optionally augments the query.
  """
  @spec get!(String.t() | integer(), keyword()) :: Sensor.t()
  def get!(id, opts \\ []) do
    SensorQueries.get(id)
    |> SensorQueries.handle_opts(opts)
    |> Repo.one!()
  end
end
