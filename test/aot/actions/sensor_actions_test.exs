defmodule Aot.Testing.SensorActionsTest do
  use Aot.Testing.DataCase

  alias Aot.SensorActions

  describe "create/1" do
    test "with a good set of parameters, it should create the path attribute" do
      {:ok, sensor} = SensorActions.create(
        ontology: "/sensing/gasses/co",
        subsystem: "chemsense",
        sensor: "co",
        parameter: "concentration"
      )

      assert sensor.path == "chemsense.co.concentration"
    end

    @tag build: :sensor
    test "a non-unique set of {subsystem, sensor, parameter} should error", %{sensor: sensor} do
      {:error, changeset} = SensorActions.create(
        ontology: "/sensing/meteorology/temperature",
        subsystem: sensor.subsystem,
        sensor: sensor.sensor,
        parameter: sensor.parameter
      )

      assert errors_on(changeset).subsystem == ["the set of {subsystem, sensor, parameter} has already been taken"]
    end
  end

  describe "update/2" do
    @moduletag build: :sensor

    test "changing any combination of {subsystem, sensor, parameter} will update the path", %{sensor: sensor} do
      {:ok, updated} = SensorActions.update(sensor, parameter: "humidity")

      refute updated.path == sensor.path
      assert updated.path == "metsense.tsys01.humidity"
    end

    test "a non-unique set of {subsystem, sensor, parameter} should error", %{sensor: sensor} do
      {:ok, other} = SensorActions.create(
        ontology: "/sensing/meteorology/temperature",
        subsystem: sensor.subsystem,
        sensor: sensor.sensor,
        parameter: "whatever"
      )

      {:error, changeset} = SensorActions.update(sensor, parameter: other.parameter)
      assert errors_on(changeset).subsystem == ["the set of {subsystem, sensor, parameter} has already been taken"]
    end
  end

  describe "get!/1" do
    @moduletag build: :sensor

    test "with an id", %{sensor: sensor} do
      found = SensorActions.get!(sensor.id)
      assert found.path == sensor.path
    end

    test "with a path", %{sensor: sensor} do
      found = SensorActions.get!(sensor.path)
      assert found.id == sensor.id
    end

    test "with an unknown id should error" do
      assert_raise Ecto.NoResultsError, fn ->
        SensorActions.get!(123456789)
      end
    end

    test "with an unknown path should error" do
      assert_raise Ecto.NoResultsError, fn ->
        SensorActions.get!("i.don't.exist")
      end
    end
  end

  describe "get!/2" do
    @moduletag build: :sensor

    test "using the include_networks option will embed the list of associated networks", %{sensor: sensor} do
      found = SensorActions.get!(sensor.id)
      refute Ecto.assoc_loaded?(found.networks)

      found = SensorActions.get!(sensor.id, include_networks: true)
      assert Ecto.assoc_loaded?(found.networks)
    end
  end

  describe "list/0" do
    @moduletag build: :sensor

    test "gets all sensors" do
      sensors = SensorActions.list()
      assert length(sensors) == 1
    end
  end

  describe "list/1" do
    @moduletag build: :sensor

    test "using the include_networks option will embed the list of associated networks" do
      SensorActions.list()
      |> Enum.each(& refute Ecto.assoc_loaded?(&1.networks))

      SensorActions.list(include_networks: true)
      |> Enum.each(& assert Ecto.assoc_loaded?(&1.networks))
    end
  end
end
