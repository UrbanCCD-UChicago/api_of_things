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
  Creates a new Sensor.
  """
  @spec create(keyword() | map()) :: {:ok, Aot.Sensor.t()} | {:error, Ecto.Changeset.t()}
  def create(params) do
    params = atomize(params)

    Sensor.changeset(%Sensor{}, params)
    |> Repo.insert()
  end

  @doc """
  Updates an existing Sensor.
  """
  @spec update(Sensor.t(), keyword() | map()) :: {:ok, Aot.Sensor.t()} | {:error, Ecto.Changeset.t()}
  def update(sensor, params) do
    params = atomize(params)

    Sensor.changeset(sensor, params)
    |> Repo.update()
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
  @spec get(String.t() | integer(), keyword()) :: {:ok, Sensor.t()} | {:error, :not_found}
  def get(path, opts \\ []) do
    res =
      SensorQueries.get(path)
      |> SensorQueries.handle_opts(opts)
      |> Repo.one()

    case res do
      nil -> {:error, :not_found}
      sensor -> {:ok, sensor}
    end
  end
end
