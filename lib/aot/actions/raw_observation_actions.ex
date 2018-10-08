defmodule Aot.RawObservationActions do
  @moduledoc """
  The internal API for working with RawObservations.
  """

  import Aot.ActionUtils

  alias Aot.{
    RawObservation,
    RawObservationQueries,
    Repo
  }

  @doc """
  Creates a new RawObservation.
  """
  @spec create(map() | keyword()) :: {:ok, RawObservation.t()} | {:error, Ecto.Changeset.t()}
  def create(params) do
    params =
      params
      |> atomize()
      |> parse_rel(:node)
      |> parse_rel(:sensor)

    RawObservation.changeset(%RawObservation{}, params)
    |> Repo.insert(on_conflict: :nothing)
  end

  @doc """
  Gets a list of RawObservations and optionally augments the query.
  """
  @spec list(keyword()) :: list(RawObservation.t())
  def list(opts \\ []) do
    RawObservationQueries.list()
    |> RawObservationQueries.handle_opts(opts)
    |> Repo.all()
  end

  def data_csv_row_to_params(%{"parameter" => "id"}, _), do: nil
  def data_csv_row_to_params(%{"value_raw" => value}, _) when not is_number(value), do: nil
  def data_csv_row_to_params(row, sensors) do
    path = "#{row["subsystem"]}.#{row["sensor"]}.#{row["parameter"]}"
    sensor = Map.get(sensors, path)

    %{
      node_id: row["node_id"],
      sensor_id: sensor.id,
      timestamp: parse_timestamp(row["timestamp"]),
      hrf: row["value_hrf"],
      raw: row["value_raw"]
    }
  end
end
