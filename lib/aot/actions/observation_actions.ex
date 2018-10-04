defmodule Aot.ObservationActions do
  @moduledoc """
  The internal API for working with Observations.
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
