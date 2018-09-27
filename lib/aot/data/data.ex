defmodule Aot.Data do
  @moduledoc """
  The Data context.
  """

  import Ecto.Query, warn: false
  alias Aot.Repo

  alias Aot.Data.Observation

  @doc """
  Returns the list of observations.

  ## Examples

      iex> list_observations()
      [%Observation{}, ...]

  """
  def list_observations do
    Repo.all(Observation)
  end

  @doc """
  Gets a single observation.

  Raises `Ecto.NoResultsError` if the Observation does not exist.

  ## Examples

      iex> get_observation!(123)
      %Observation{}

      iex> get_observation!(456)
      ** (Ecto.NoResultsError)

  """
  def get_observation!(id), do: Repo.get!(Observation, id)

  @doc """
  Creates a observation.

  ## Examples

      iex> create_observation(%{field: value})
      {:ok, %Observation{}}

      iex> create_observation(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_observation(attrs \\ %{}) do
    %Observation{}
    |> Observation.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a observation.

  ## Examples

      iex> update_observation(observation, %{field: new_value})
      {:ok, %Observation{}}

      iex> update_observation(observation, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_observation(%Observation{} = observation, attrs) do
    observation
    |> Observation.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Observation.

  ## Examples

      iex> delete_observation(observation)
      {:ok, %Observation{}}

      iex> delete_observation(observation)
      {:error, %Ecto.Changeset{}}

  """
  def delete_observation(%Observation{} = observation) do
    Repo.delete(observation)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking observation changes.

  ## Examples

      iex> change_observation(observation)
      %Ecto.Changeset{source: %Observation{}}

  """
  def change_observation(%Observation{} = observation) do
    Observation.changeset(observation, %{})
  end

  alias Aot.Data.RawObservation

  @doc """
  Returns the list of raw_observations.

  ## Examples

      iex> list_raw_observations()
      [%RawObservation{}, ...]

  """
  def list_raw_observations do
    Repo.all(RawObservation)
  end

  @doc """
  Gets a single raw_observation.

  Raises `Ecto.NoResultsError` if the Raw observation does not exist.

  ## Examples

      iex> get_raw_observation!(123)
      %RawObservation{}

      iex> get_raw_observation!(456)
      ** (Ecto.NoResultsError)

  """
  def get_raw_observation!(id), do: Repo.get!(RawObservation, id)

  @doc """
  Creates a raw_observation.

  ## Examples

      iex> create_raw_observation(%{field: value})
      {:ok, %RawObservation{}}

      iex> create_raw_observation(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_raw_observation(attrs \\ %{}) do
    %RawObservation{}
    |> RawObservation.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a raw_observation.

  ## Examples

      iex> update_raw_observation(raw_observation, %{field: new_value})
      {:ok, %RawObservation{}}

      iex> update_raw_observation(raw_observation, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_raw_observation(%RawObservation{} = raw_observation, attrs) do
    raw_observation
    |> RawObservation.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a RawObservation.

  ## Examples

      iex> delete_raw_observation(raw_observation)
      {:ok, %RawObservation{}}

      iex> delete_raw_observation(raw_observation)
      {:error, %Ecto.Changeset{}}

  """
  def delete_raw_observation(%RawObservation{} = raw_observation) do
    Repo.delete(raw_observation)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking raw_observation changes.

  ## Examples

      iex> change_raw_observation(raw_observation)
      %Ecto.Changeset{source: %RawObservation{}}

  """
  def change_raw_observation(%RawObservation{} = raw_observation) do
    RawObservation.changeset(raw_observation, %{})
  end
end
