defmodule Aot.ObservationActions do
  @moduledoc """
  The internal API for working with Observations.

  /observations
    ?timestamp=gt:2018-01-01T00:00:00
    &distance_within=2000:1,-2
    &metsense.tsys01.temperature=between:20,25
    &include_raw=true

  [
    timestamp_op: {:gt, ~N[2018-01-01 00:00:00]},
    distance_within: {%Geo.Point{srid: 4326, coordinates: {1, -2}}},
    for_sensor: "metsense.tsys01.temperature",
    value: {:between, {20, 25}},
    assert_hrf: true,
    assert_raw: true,
  ]
  """

  import Aot.ActionUtils

  alias Aot.{
    Observation,
    ObservationQueries,
    Repo
  }

  @doc """
  Creates a new Observation.
  """
  @spec create(map() | keyword()) :: {:ok, Observation.t()} | {:error, Ecto.Changeset.t()}
  def create(params) do
    params =
      params
      |> atomize()
      |> parse_rel(:node)
      |> parse_rel(:sensor)

    Observation.changeset(%Observation{}, params)
    |> Repo.insert(on_conflict: :nothing)
  end

  @doc """
  Gets a list of Observations and optionally augments the query.
  """
  @spec list(keyword()) :: list(Observation.t())
  def list(opts \\ []) do
    ObservationQueries.list()
    |> ObservationQueries.handle_opts(opts)
    |> Repo.all()
  end
end
