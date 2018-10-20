NimbleCSV.define(DataCsv, separator: ",", escape: "\"")

defmodule AotJobs.Importer do
  @moduledoc """
  """

  require Logger

  import Ecto.Query

  alias Aot.{
    ProjectActions,
    ProjectNode,
    ProjectSensor,
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
  @spec import(Aot.Project.t()) :: :ok
  def import(project) do
    _ = Logger.info("importing data for #{project.name}")

    tarball = Path.join(@dirname, "#{project.slug}.tar")

    :ok = ensure_clean_paths!(tarball)
    :ok = download!(project, tarball)
    data_dir = decompress!(project, tarball)
    project = process_provenance_csv!(project, data_dir)
    :ok = process_nodes_csv!(project, data_dir)
    :ok = process_sensors_csv!(project, data_dir)
    :ok = process_data_csv!(project, data_dir)
    :ok = process_nodes_sensors!(project, data_dir)

    bbox = ProjectActions.compute_bbox(project)
    hull = ProjectActions.compute_hull(project)
    {:ok, _} = ProjectActions.update(project, bbox: bbox, hull: hull)

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

  defp download!(project, tarball) do
    _ = Logger.info("downloading tarball for #{project.name}")
    _ = Logger.debug("url: #{project.recent_url}")
    _ = Logger.debug("tarball: #{tarball}")
    %HTTPoison.Response{body: body} = HTTPoison.get!(project.recent_url)

    _ = Logger.debug("download complete")
    _ = Logger.debug("writing to file")

    File.write!(tarball, body)

    _ = Logger.debug("write complete")
    :ok
  end

  defp decompress!(project, tarball) do
    _ = Logger.info("decompressing tarball for #{project.name}")

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

  defp process_provenance_csv!(project, data_dir) do
    _ = Logger.info("ripping provenance csv for #{project.name}")

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

    {:ok, updated} = ProjectActions.update(project, params)
    updated
  end

  defp process_nodes_csv!(project, data_dir) do
    nodes =
      NodeActions.list()
      |> Enum.map(& {&1.vsn, &1})
      |> Enum.into(%{})

    net_nodes =
      NodeActions.list(within_project: project)
      |> Enum.map(& &1.vsn)
      |> MapSet.new()

    _ = Logger.info("ripping nodes csv for #{project.name}")

    {:ok, _} =
      Path.join(data_dir, @nodes_csv)
      |> File.stream!()
      |> CSV.decode!(headers: true)
      |> Enum.reduce(Ecto.Multi.new(), fn row, multi ->
        vsn = row["vsn"]

        multi =
          case Map.get(nodes, vsn) do
            nil ->
              name = "insert node #{vsn}"
              Ecto.Multi.insert(multi, name, Node.changeset(%Node{}, node_params(row)))

            node ->
              name = "update node #{vsn}"
              Ecto.Multi.update(multi, name, Node.changeset(node, node_params(row)))
          end

        case MapSet.member?(net_nodes, vsn) do
          true ->
            multi

          false ->
            name = "insert project/node #{project.slug} #{vsn}"
            Ecto.Multi.insert(multi, name, ProjectNode.changeset(%ProjectNode{},
              %{project_slug: project.slug, node_vsn: vsn}))
        end
      end)
      |> Repo.transaction()

    :ok
  end

  defp process_sensors_csv!(project, data_dir) do
    sensors =
      SensorActions.list()
      |> Enum.map(& {&1.path, &1})
      |> Enum.into(%{})

    net_sensors =
      SensorActions.list(observes_project: project)
      |> Enum.map(& &1.path)
      |> MapSet.new()

    _ = Logger.info("ripping sensors csv for #{project.name}")

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
                  name = "insert sensor #{path}"
                  Ecto.Multi.insert(multi, name, Sensor.changeset(%Sensor{}, sensor_params(row)))

                sensor ->
                  name = "update sensor #{path}"
                  Ecto.Multi.update(multi, name, Sensor.changeset(sensor, sensor_params(row)))
              end

            case MapSet.member?(net_sensors, path) do
              true ->
                multi

              false ->
                name = "insert project/sensor #{project.slug} #{path}"
                Ecto.Multi.insert(multi, name, ProjectSensor.changeset(%ProjectSensor{},
                  %{project_slug: project.slug, sensor_path: path}))
            end
        end
      end)
      |> Repo.transaction()

    :ok
  end

  defp process_data_csv!(project, data_dir) do
    # get the exisitng node ids
    nodes =
      NodeActions.list(in_project: project)
      |> Enum.map(& {&1.id, &1.vsn})
      |> Enum.into(%{})

    # get the existing sensor paths
    sensors =
      SensorActions.list(observes_project: project)
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
    _ = Logger.info("ripping data csv for #{project.name}")

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
                        vsn = Map.get(nodes, node_id)
                        name = "insert observation #{vsn} #{sensor_path} #{timestamp}"
                        Ecto.Multi.insert(multi, name, Observation.changeset(%Observation{},
                          %{node_vsn: vsn, sensor_path: sensor_path, timestamp: timestamp, value: hrf}))
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
                      vsn = Map.get(nodes, node_id)
                      name = "insert raw observation #{vsn} #{sensor_path} #{timestamp}"
                      Ecto.Multi.insert(multi, name, RawObservation.changeset(%RawObservation{},
                        %{node_vsn: vsn, sensor_path: sensor_path, timestamp: timestamp, hrf: hrf, raw: raw}))
                  end
              end

          end
        end)
        |> Repo.transaction()
    end, async_opts)
    |> Stream.run()

    :ok
  end

  defp process_nodes_sensors!(project, data_dir) do
    # get existing nodes
    vsns =
      NodeActions.list(within_project: project)
      |> Enum.map(& &1.vsn)

    nodes =
      NodeActions.list(within_project: project)
      |> Enum.map(& {&1.id, &1.vsn})
      |> Enum.into(%{})

    vsn2id =
      nodes
      |> Enum.map(fn {id, vsn} -> {vsn, id} end)
      |> Enum.into(%{})

    # get existing sensors
    sensors =
      SensorActions.list(observes_project: project)
      |> Enum.map(& &1.path)
      |> MapSet.new()

    # get the existing node/sensors
    nodes_sensors =
      Repo.all(from ns in NodeSensor, where: ns.node_vsn in ^vsns)
      |> Enum.map(& {Map.get(vsn2id, &1.node_vsn), &1.sensor_path})
      |> MapSet.new()

    # stream the csv file
    _ = Logger.info("ripping data csv for #{project.name} (nodes/sensors run)")

    {multi, _} =
      Path.join(data_dir, @data_csv)
      |> File.stream!()
      |> CSV.decode!(headers: true)
      |> Enum.reduce({Ecto.Multi.new(), nodes_sensors}, fn row, {multi, nodes_sensors} ->
        node_id = row["node_id"]
        sensor_path = make_sensor_path(row)

        case (row["parameter"] == "id" or
          row["hrf_unit"] == "bool" or
          not Map.has_key?(nodes, node_id) or
          not MapSet.member?(sensors, sensor_path) or
          MapSet.member?(nodes_sensors, {node_id, sensor_path}))
        do
          true ->
            {multi, nodes_sensors}

          false ->
            vsn = Map.get(nodes, node_id)
            nodes_sensors = MapSet.put(nodes_sensors, {node_id, sensor_path})
            name = "insert node/sensor #{vsn} #{sensor_path}"
            multi =Ecto.Multi.insert(multi, name, NodeSensor.changeset(%NodeSensor{},
              %{node_vsn: vsn, sensor_path: sensor_path}))
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

  defp skip_node_id?(node_id, nodes), do: not Map.has_key?(nodes, node_id)

  defp skip_sensor_path?(path, sensors), do: not MapSet.member?(sensors, path)

  defp parse_value(""), do: nil
  defp parse_value(nil), do: nil
  defp parse_value(value) do
    case Regex.match?(~r/^\-?[\d\.]+$/, value) do
      false ->
        nil

      true ->
        case Float.parse(value) do
          :error -> nil
          {parsed, _} -> parsed
        end
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
