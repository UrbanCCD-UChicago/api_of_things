defmodule AotIngest.Loaders do
  @moduledoc """
  """

  require Logger

  alias Aot.{
    Node,
    NodeActions,
    Observation,
    ObservationActions,
    RawObservation,
    RawObservationActions,
    Repo,
    Sensor,
    SensorActions
  }

  alias Ecto.Multi

  def load_nodes_csv(path) do
    existing_nodes =
      NodeActions.list()
      |> Enum.map(& {&1.id, &1})
      |> Enum.into(%{})

    {multi, node_ids} =
      path
      |> File.stream!()
      |> CSV.decode!(headers: true)
      |> Enum.map(&NodeActions.node_csv_row_to_params/1)
      |> Enum.reduce({Multi.new(), []}, fn params, {multi, node_ids} ->
        id = Map.get(params, :id)
        node_ids = [id | node_ids]

        multi =
          case Map.get(existing_nodes, id) do
            nil ->
              name = String.to_atom("insert_node_#{id}")
              Multi.insert(multi, name, Node.changeset(%Node{}, params))

            node ->
              name = String.to_atom("update_node_#{id}")
              Multi.update(multi, name, Node.changeset(node, params))
          end

        {multi, node_ids}
      end)

    case Repo.transaction(multi) do
      {:ok, _} ->
        Logger.info("successfully loaded nodes.csv")

      {:error, errors} ->
        Logger.error("#{inspect(errors)}")
    end

    node_ids
  end

  def load_sensors_csv(path) do
    existing_sensors =
      SensorActions.list()
      |> Enum.map(& {&1.path, &1})
      |> Enum.into(%{})

    {multi, sensor_paths} =
      path
      |> File.stream!()
      |> CSV.decode!(headers: true)
      |> Enum.map(&SensorActions.sensor_csv_row_to_params/1)
      |> Enum.reject(&is_nil/1)
      |> Enum.reduce({Multi.new(), []}, fn params, {multi, sensor_paths} ->
        path = "#{params.subsystem}.#{params.sensor}.#{params.parameter}"
        sensor_paths = [path | sensor_paths]

        multi =
          case Map.get(existing_sensors, path) do
            nil ->
              name = String.to_atom("insert_sensor_#{path}")
              Multi.insert(multi, name, Sensor.changeset(%Sensor{}, params))

            sensor ->
              name = String.to_atom("update_sensor_#{path}")
              Multi.update(multi, name, Sensor.changeset(sensor, params))
          end

        {multi, sensor_paths}
      end)

      case Repo.transaction(multi) do
        {:ok, _} ->
          Logger.info("successfully loaded sensors.csv")

        {:error, errors} ->
          Logger.error("#{inspect(errors)}")
      end

      sensor_paths
  end

  def load_data_csv(path) do
    sensors =
      SensorActions.list()
      |> Enum.map(& {&1.path, &1})
      |> Enum.into(%{})

    {multi, nodes_sensors} =
      path
      |> File.stream!()
      |> CSV.decode!(headers: true)
      |> Enum.map(& {ObservationActions.data_csv_row_to_params(&1, sensors), RawObservationActions.data_csv_row_to_params(&1, sensors)})
      |> Enum.with_index()
      |> Enum.reduce({Multi.new(), []}, fn {{reg, raw}, idx}, {multi, nodes_sensors} ->
        {multi, nodes_sensors} =
          case reg do
            nil ->
              {multi, nodes_sensors}

            params ->
              name = String.to_atom("insert_obs_line_#{idx}")
              multi = Multi.insert(multi, name, Observation.changeset(%Observation{}, params))
              nodes_sensors = [{params.node_id, params.sensor_id}]
              {multi, nodes_sensors}
          end

        case raw do
          nil ->
            {multi, nodes_sensors}

          params ->
            name = String.to_atom("insert_raw_obs_line_#{idx}")
            multi = Multi.insert(multi, name, RawObservation.changeset(%RawObservation{}, params))
            nodes_sensors = [{params.node_id, params.sensor_id}]
            {multi, nodes_sensors}
        end
      end)

    case Repo.transaction(multi) do
      {:ok, _} ->
        Logger.info("successfully loaded data.csv")

      {:error, errors} ->
        Logger.error("#{inspect(errors)}")
    end

    nodes_sensors
    |> Enum.uniq()
  end
end
