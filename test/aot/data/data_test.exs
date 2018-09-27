defmodule Aot.DataTest do
  use Aot.DataCase

  alias Aot.Data

  describe "observations" do
    alias Aot.Data.Observation

    @valid_attrs %{node: "some node", sensor: "some sensor", timestamp: ~N[2010-04-17 14:00:00.000000], value: 120.5}
    @update_attrs %{node: "some updated node", sensor: "some updated sensor", timestamp: ~N[2011-05-18 15:01:01.000000], value: 456.7}
    @invalid_attrs %{node: nil, sensor: nil, timestamp: nil, value: nil}

    def observation_fixture(attrs \\ %{}) do
      {:ok, observation} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Data.create_observation()

      observation
    end

    test "list_observations/0 returns all observations" do
      observation = observation_fixture()
      assert Data.list_observations() == [observation]
    end

    test "get_observation!/1 returns the observation with given id" do
      observation = observation_fixture()
      assert Data.get_observation!(observation.id) == observation
    end

    test "create_observation/1 with valid data creates a observation" do
      assert {:ok, %Observation{} = observation} = Data.create_observation(@valid_attrs)
      assert observation.node == "some node"
      assert observation.sensor == "some sensor"
      assert observation.timestamp == ~N[2010-04-17 14:00:00.000000]
      assert observation.value == 120.5
    end

    test "create_observation/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Data.create_observation(@invalid_attrs)
    end

    test "update_observation/2 with valid data updates the observation" do
      observation = observation_fixture()
      assert {:ok, observation} = Data.update_observation(observation, @update_attrs)
      assert %Observation{} = observation
      assert observation.node == "some updated node"
      assert observation.sensor == "some updated sensor"
      assert observation.timestamp == ~N[2011-05-18 15:01:01.000000]
      assert observation.value == 456.7
    end

    test "update_observation/2 with invalid data returns error changeset" do
      observation = observation_fixture()
      assert {:error, %Ecto.Changeset{}} = Data.update_observation(observation, @invalid_attrs)
      assert observation == Data.get_observation!(observation.id)
    end

    test "delete_observation/1 deletes the observation" do
      observation = observation_fixture()
      assert {:ok, %Observation{}} = Data.delete_observation(observation)
      assert_raise Ecto.NoResultsError, fn -> Data.get_observation!(observation.id) end
    end

    test "change_observation/1 returns a observation changeset" do
      observation = observation_fixture()
      assert %Ecto.Changeset{} = Data.change_observation(observation)
    end
  end

  describe "raw_observations" do
    alias Aot.Data.RawObservation

    @valid_attrs %{node: "some node", sensor: "some sensor", timestamp: ~N[2010-04-17 14:00:00.000000], value: 120.5}
    @update_attrs %{node: "some updated node", sensor: "some updated sensor", timestamp: ~N[2011-05-18 15:01:01.000000], value: 456.7}
    @invalid_attrs %{node: nil, sensor: nil, timestamp: nil, value: nil}

    def raw_observation_fixture(attrs \\ %{}) do
      {:ok, raw_observation} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Data.create_raw_observation()

      raw_observation
    end

    test "list_raw_observations/0 returns all raw_observations" do
      raw_observation = raw_observation_fixture()
      assert Data.list_raw_observations() == [raw_observation]
    end

    test "get_raw_observation!/1 returns the raw_observation with given id" do
      raw_observation = raw_observation_fixture()
      assert Data.get_raw_observation!(raw_observation.id) == raw_observation
    end

    test "create_raw_observation/1 with valid data creates a raw_observation" do
      assert {:ok, %RawObservation{} = raw_observation} = Data.create_raw_observation(@valid_attrs)
      assert raw_observation.node == "some node"
      assert raw_observation.sensor == "some sensor"
      assert raw_observation.timestamp == ~N[2010-04-17 14:00:00.000000]
      assert raw_observation.value == 120.5
    end

    test "create_raw_observation/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Data.create_raw_observation(@invalid_attrs)
    end

    test "update_raw_observation/2 with valid data updates the raw_observation" do
      raw_observation = raw_observation_fixture()
      assert {:ok, raw_observation} = Data.update_raw_observation(raw_observation, @update_attrs)
      assert %RawObservation{} = raw_observation
      assert raw_observation.node == "some updated node"
      assert raw_observation.sensor == "some updated sensor"
      assert raw_observation.timestamp == ~N[2011-05-18 15:01:01.000000]
      assert raw_observation.value == 456.7
    end

    test "update_raw_observation/2 with invalid data returns error changeset" do
      raw_observation = raw_observation_fixture()
      assert {:error, %Ecto.Changeset{}} = Data.update_raw_observation(raw_observation, @invalid_attrs)
      assert raw_observation == Data.get_raw_observation!(raw_observation.id)
    end

    test "delete_raw_observation/1 deletes the raw_observation" do
      raw_observation = raw_observation_fixture()
      assert {:ok, %RawObservation{}} = Data.delete_raw_observation(raw_observation)
      assert_raise Ecto.NoResultsError, fn -> Data.get_raw_observation!(raw_observation.id) end
    end

    test "change_raw_observation/1 returns a raw_observation changeset" do
      raw_observation = raw_observation_fixture()
      assert %Ecto.Changeset{} = Data.change_raw_observation(raw_observation)
    end
  end
end
