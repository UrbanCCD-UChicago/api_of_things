NimbleCSV.define(DataCsv, separator: ",", escape: "\"")

defmodule AotJobs.Importer do
  @moduledoc """
  """

  require Logger

  import Ecto.Query

  alias Aot.{
    NetworkActions,
    NetworkNode,
    NetworkSensor,
    Node,
    NodeActions,
    NodeSensor,
    Observation,
    RawObservation,
    Repo,
    Sensor,
    SensorActions
  }

  @dirname "/tmp/aot-tarballs/"

  @prov_csv "provenance.csv"

  @nodes_csv "nodes.csv"

  @sensors_csv "sensors.csv"

  @data_csv "data.csv"

  @data_gz "data.csv.gz"

  @data_chunk 1_000 # rows

  @data_headers ~w(timestamp node_id subsystem sensor parameter value_raw value_hrf)

  @doc """
  """
  @spec import(Aot.Network.t()) :: :ok
  def import(network) do
    _ = Logger.info("importing data for #{network.name}")

    tarball = Path.join(@dirname, "#{network.slug}.tar")

    :ok = ensure_clean_paths!(tarball)
    :ok = download!(network, tarball)
    data_dir = decompress!(network, tarball)
    network = process_provenance_csv!(network, data_dir)
    :ok = process_nodes_csv!(network, data_dir)
    :ok = process_sensors_csv!(network, data_dir)
    :ok = process_data_csv!(network, data_dir)
    :ok = process_nodes_sensors!(network, data_dir)
    :ok
  after
    _ = Logger.info("cleaning up #{@dirname}")
    _ = System.cmd("rm", ["-r", @dirname])
    :ok
  end

  defp ensure_clean_paths!(tarball) do
    _ = System.cmd("rm", ["-r", @dirname])
    _ = System.cmd("mkdir", ["-p", @dirname])
    _ = System.cmd("touch", [tarball])
    :ok
  end

  defp download!(network, tarball) do
    _ = Logger.info("downloading tarball for #{network.name}")
    _ = Logger.debug("url: #{network.recent_url}")
    _ = Logger.debug("tarball: #{tarball}")
    %HTTPoison.Response{body: body} = HTTPoison.get!(network.recent_url)

    _ = Logger.debug("download complete")
    _ = Logger.debug("writing to file")

    File.write!(tarball, body)

    _ = Logger.debug("write complete")
    :ok
  end

  defp decompress!(network, tarball) do
    _ = Logger.info("decompressing tarball for #{network.name}")

    {paths, 0} = System.cmd("tar", ["tf", tarball])

    dir =
      String.split(paths, "\n")
      |> List.first()

    {_, 0} = System.cmd("tar", ["xf", tarball, "--directory", @dirname])

    _ = Logger.debug("decompress tarball complete")
    _ = Logger.debug("decompressing data csv")

    data_dir = Path.join(@dirname, dir)
    data_gz = Path.join(data_dir, @data_gz)

    {_, 0} = System.cmd("gunzip", [data_gz])

    _ = Logger.debug("decompress data csv complete")
    data_dir
  end

  defp process_provenance_csv!(network, data_dir) do
    _ = Logger.info("ripping provenance csv for #{network.name}")

    raw_params =
      Path.join(data_dir, @prov_csv)
      |> File.stream!()
      |> CSV.decode!(headers: true)
      |> Stream.map(& &1)
      |> Enum.take(1)
      |> List.first()

    params = %{
      first_observation: parse_ts(raw_params["data_start_date"]),
      latest_observation: parse_ts(raw_params["data_end_date"]),
      archive_url: raw_params["url"]
    }

    {:ok, updated} = NetworkActions.update(network, params)
    updated
  end

  defp process_nodes_csv!(network, data_dir) do
    nodes =
      NodeActions.list()
      |> Enum.map(& {&1.id, &1})
      |> Enum.into(%{})

    net_nodes =
      NodeActions.list(within_network: network)
      |> Enum.map(& &1.id)
      |> MapSet.new()

    _ = Logger.info("ripping nodes csv for #{network.name}")

    {:ok, _} =
      Path.join(data_dir, @nodes_csv)
      |> File.stream!()
      |> CSV.decode!(headers: true)
      |> Enum.reduce(Ecto.Multi.new(), fn row, multi ->
        node_id = row["node_id"]

        multi =
          case Map.get(nodes, node_id) do
            nil ->
              name = :"insert node #{node_id}"
              Ecto.Multi.insert(multi, name, Node.changeset(%Node{}, node_params(row)))

            node ->
              name = :"update node #{node_id}"
              Ecto.Multi.update(multi, name, Node.changeset(node, node_params(row)))
          end

        case MapSet.member?(net_nodes, node_id) do
          true ->
            multi

          false ->
            name = :"insert network/node #{network.slug} #{node_id}"
            Ecto.Multi.insert(multi, name, NetworkNode.changeset(%NetworkNode{},
              %{network_slug: network.slug, node_id: node_id}))
        end
      end)
      |> Repo.transaction()

    :ok
  end

  defp process_sensors_csv!(network, data_dir) do
    sensors =
      SensorActions.list()
      |> Enum.map(& {&1.path, &1})
      |> Enum.into(%{})

    net_sensors =
      SensorActions.list(observes_network: network)
      |> Enum.map(& &1.path)
      |> MapSet.new()

    _ = Logger.info("ripping sensors csv for #{network.name}")

    {:ok, _} =
      Path.join(data_dir, @sensors_csv)
      |> File.stream!()
      |> CSV.decode!(headers: true)
      |> Enum.reduce(Ecto.Multi.new(), fn row, multi ->
        path = make_sensor_path(row)

        case row["parameter"] == "id" or row["hrf_unit"] == "bool" do
          true ->
            multi

          false ->
            multi =
              case Map.get(sensors, path) do
                nil ->
                  name = :"insert sensor #{path}"
                  Ecto.Multi.insert(multi, name, Sensor.changeset(%Sensor{}, sensor_params(row)))

                sensor ->
                  name = :"update sensor #{path}"
                  Ecto.Multi.update(multi, name, Sensor.changeset(sensor, sensor_params(row)))
              end

            case MapSet.member?(net_sensors, path) do
              true ->
                multi

              false ->
                name = :"insert network/sensor #{network.slug} #{path}"
                Ecto.Multi.insert(multi, name, NetworkSensor.changeset(%NetworkSensor{},
                  %{network_slug: network.slug, sensor_path: path}))
            end
        end
      end)
      |> Repo.transaction()

    :ok
  end

  defp process_data_csv!(network, data_dir) do
    # get the exisitng node ids
    nodes =
      NodeActions.list(in_network: network)
      |> Enum.map(& &1.id)
      |> MapSet.new()

    # get the existing sensor paths
    sensors =
      SensorActions.list(observes_network: network)
      |> Enum.map(& &1.path)
      |> MapSet.new()

    # get the latest observation timestamp
    latest_observation =
      (from o in Observation, select: max(o.timestamp))
      |> Repo.one()

    # get the latest raw observation timestamp
    latest_raw_observation =
      (from r in RawObservation, select: max(r.timestamp))
      |> Repo.one()

    # stream the csv file
    _ = Logger.info("ripping data csv for #{network.name}")

    async_opts = Application.get_env(:aot, :import_concurrency)

    Path.join(data_dir, @data_csv)
    |> File.stream!()
    |> DataCsv.parse_stream(headers: true)
    |> Stream.chunk_every(@data_chunk)
    |> Task.async_stream(fn rows ->
      _ = Logger.debug("processeing data csv batch")

      {:ok, _} =
        rows
        |> Enum.reduce(Ecto.Multi.new(), fn raw_row, multi ->
          row =
            Enum.zip(@data_headers, raw_row)
            |> Enum.into(%{})

          node_id = row["node_id"]
          sensor_path = make_sensor_path(row)
          timestamp = parse_ts(row["timestamp"])
          hrf = parse_value(row["value_hrf"])
          raw = parse_value(row["value_raw"])

          case skip_node_id?(node_id, nodes) or skip_sensor_path?(sensor_path, sensors) do
            true ->
              multi

            false ->
              # add observation
              multi =
                case skip_timestamp?(timestamp, latest_observation) do
                  true ->
                    multi

                  false ->
                    case hrf do
                      nil ->
                        multi

                      _ ->
                        name = :"insert observation #{node_id} #{sensor_path} #{timestamp}"
                        Ecto.Multi.insert(multi, name, Observation.changeset(%Observation{},
                          %{node_id: node_id, sensor_path: sensor_path, timestamp: timestamp, value: hrf}))
                    end
                end

              # add raw observation
              case skip_timestamp?(timestamp, latest_raw_observation) do
                true ->
                  multi

                false ->
                  case raw do
                    nil ->
                      multi

                    _ ->
                      name = :"insert raw observation #{node_id} #{sensor_path} #{timestamp}"
                      Ecto.Multi.insert(multi, name, RawObservation.changeset(%RawObservation{},
                        %{node_id: node_id, sensor_path: sensor_path, timestamp: timestamp, hrf: hrf, raw: raw}))
                  end
              end

          end
        end)
        |> Repo.transaction()
    end, async_opts)
    |> Stream.run()

    :ok
  end

  defp process_nodes_sensors!(network, data_dir) do
    # get existing nodes
    nodes =
      NodeActions.list(within_network: network)
      |> Enum.map(& &1.id)

    # get existing sensors
    sensors =
      SensorActions.list(observes_network: network)
      |> Enum.map(& &1.path)
      |> MapSet.new()

    # get the existing node/sensors
    nodes_sensors =
      Repo.all(from ns in NodeSensor, where: ns.node_id in ^nodes)
      |> Enum.map(& {&1.node_id, &1.sensor_path})
      |> MapSet.new()

    nodes = MapSet.new(nodes)

    # stream the csv file
    _ = Logger.info("ripping data csv for #{network.name} (nodes/sensors run)")

    {multi, _} =
      Path.join(data_dir, @data_csv)
      |> File.stream!()
      |> CSV.decode!(headers: true)
      |> Enum.reduce({Ecto.Multi.new(), nodes_sensors}, fn row, {multi, nodes_sensors} ->
        node_id = row["node_id"]
        sensor_path = make_sensor_path(row)

        case (row["parameter"] == "id" or
          row["hrf_unit"] == "bool" or
          not MapSet.member?(nodes, node_id) or
          not MapSet.member?(sensors, sensor_path) or
          MapSet.member?(nodes_sensors, {node_id, sensor_path}))
        do
          true ->
            {multi, nodes_sensors}

          false ->
            nodes_sensors = MapSet.put(nodes_sensors, {node_id, sensor_path})
            name = :"insert node/sensor #{node_id} #{sensor_path}"
            multi =Ecto.Multi.insert(multi, name, NodeSensor.changeset(%NodeSensor{},
              %{node_id: node_id, sensor_path: sensor_path}))
            {multi, nodes_sensors}
        end
      end)

    {:ok, _} = Repo.transaction(multi)

    :ok
  end

  defp make_sensor_path(row), do: "#{row["subsystem"]}.#{row["sensor"]}.#{row["parameter"]}"

  defp parse_ts(""), do: nil
  defp parse_ts(nil), do: nil
  defp parse_ts(value), do: Timex.parse!(value, "%Y/%m/%d %H:%M:%S", :strftime)

  defp skip_timestamp?(nil, _), do: true
  defp skip_timestamp?(_, nil), do: false
  defp skip_timestamp?(ts, latest), do: NaiveDateTime.compare(ts, latest) != :gt

  defp skip_node_id?(node_id, nodes), do: not MapSet.member?(nodes, node_id)

  defp skip_sensor_path?(path, sensors), do: not MapSet.member?(sensors, path)

  defp parse_value(""), do: nil
  defp parse_value(nil), do: nil
  defp parse_value(value) do
    case Float.parse(value) do
      :error -> nil
      {parsed, _} -> parsed
    end
  end

  defp node_params(row), do: %{
    id: row["node_id"],
    vsn: row["vsn"],
    longitude: row["lon"],
    latitude: row["lat"],
    address: row["address"],
    description: row["description"],
    commissioned_on: parse_ts(row["start_timestamp"]),
    decommissioned_on: parse_ts(row["end_timestamp"])
  }

  defp sensor_params(row), do: %{
    ontology: row["ontology"],
    subsystem: row["subsystem"],
    sensor: row["sensor"],
    parameter: row["parameter"],
    uom: row["hrf_unit"],
    min: row["hrf_minval"],
    max: row["hrf_maxval"],
    data_sheet: row["datasheet"]
  }
end
