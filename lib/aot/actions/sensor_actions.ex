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

  @type ok_sensor :: {:ok, Aot.Sensor.t()} | {:error, Ecto.Changeset.t()}

  @doc """
  Creates a new Sensor.
  """
  @spec create(keyword() | map()) :: ok_sensor
  def create(params) do
    params = atomize(params)

    Sensor.changeset(%Sensor{}, params)
    |> Repo.insert()
  end

  @doc """
  Updates an existing Sensor.
  """
  @spec update(Sensor.t(), keyword() | map()) :: ok_sensor
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
  @spec get!(String.t() | integer(), keyword()) :: Sensor.t()
  def get!(id, opts \\ []) do
    SensorQueries.get(id)
    |> SensorQueries.handle_opts(opts)
    |> Repo.one!()
  end

  def sensor_csv_row_to_params(%{"parameter" => "id"}), do: nil
  def sensor_csv_row_to_params(row) do
    %{
      ontology: row["ontology"],
      subsystem: row["subsystem"],
      sensor: row["sensor"],
      parameter: row["parameter"],
      unit: row["hrf_unit"],
      min_value: row["hrf_minval"],
      max_value: row["hrf_maxval"],
      data_sheet: row["datasheet"]
    }
  end
end
