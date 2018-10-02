defmodule Aot.Testing.DataCase do
  @moduledoc """
  This module defines the setup for tests requiring
  access to the application's data layer.

  You may define functions here to be used as helpers in
  your tests.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  alias Aot.{
    NetworkActions,
    NodeActions,
    SensorActions
  }

  using do
    quote do
      alias Aot.Repo
      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import Aot.Testing.DataCase
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Aot.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Aot.Repo, {:shared, self()})
    end

    # build out context
    context = []
    build = tags[:build] || []
    build =
      case is_list(build) do
        true -> build
        false -> [build]
      end

    build_network? = :network in build
    context =
      case build_network? do
        false -> context
        true -> Keyword.merge(context, network: create_network())
      end

    build_node? = :node in build
    context =
      case build_node? do
        false -> context
        true -> Keyword.merge(context, node: create_node())
      end

    build_sensor? = :sensor in build
    context =
      case build_sensor? do
        false -> context
        true -> Keyword.merge(context, sensor: create_sensor())
      end

    {:ok, context}
  end

  @doc """
  A helper that transform changeset errors to a map of messages.

      assert {:error, changeset} = Accounts.create_user(%{password: "short"})
      assert "password is too short" in errors_on(changeset).password
      assert %{password: ["password is too short"]} = errors_on(changeset)

  """
  def errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Enum.reduce(opts, message, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end

  def create_network do
    {:ok, network} =
      NetworkActions.create(
        name: "Chicago Complete",
        archive_url: "https://example.com/archive",
        recent_url: "https://example.com/recent",
        first_observation: ~N[2018-01-01 00:00:00],
        latest_observation: NaiveDateTime.utc_now()
      )

    network
  end

  def create_node do
    {:ok, node} =
      NodeActions.create(
        id: "000123abc",
        vsn: "01A",
        longitude: -87.1234,
        latitude: 41.4321,
        commissioned_on: ~N[2018-04-21 15:00:00]
      )

    node
  end

  def create_sensor do
    {:ok, sensor} =
      SensorActions.create(
        ontology: "/sensing/meteorology/temperature",
        subsystem: "metsense",
        sensor: "tsys01",
        parameter: "temperature"
      )

    sensor
  end
end
