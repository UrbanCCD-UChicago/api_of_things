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
end
