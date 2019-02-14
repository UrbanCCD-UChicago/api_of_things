NimbleCSV.define(DataCsv, separator: ",", escape: "\"")

defmodule AotJobs.Importer do
  require Logger
  import Ecto.Query
  alias Aot.M2m.ProjectNode
  alias Aot.Nodes
  alias Aot.Nodes.Node
  alias Aot.Observations.Observation
  alias Aot.Repo
  alias Aot.Sensors
  alias Aot.Sensors.Sensor

  @dirname "/tmp/aot-tarballs/"

  def import(project) do
    Logger.info("importing data for #{project.name}")

    tarfilename = String.split(project.recent_url, "/") |> List.last()
    tarball = Path.join(@dirname, tarfilename)
    Logger.debug("tarball=#{inspect(tarball)}")

    :ok = ensure_clean_paths!(tarball)
    :ok = download!(project, tarball)

    data_dir = decompress!(project, tarball)
    Logger.debug("data_dir=#{inspect(data_dir)}")

    :ok = process_nodes_csv!(project, data_dir)
    :ok = process_sensors_csv!(project, data_dir)
    :ok = process_data_csv!(project, data_dir)
    :ok = refresh_latest_observations!()
    :ok = refresh_node_sensors!()
    :ok = broadcast_latest!()

    :ok
  after
    Logger.info("cleaning up #{@dirname}")
    _ = System.cmd("rm", ["-r", @dirname])
    :ok
  end

  def ensure_clean_paths!(tarball) do
    if File.exists?(@dirname), do: _ = System.cmd("rm", ["-r", @dirname])
    _ = System.cmd("mkdir", ["-p", @dirname])
    _ = System.cmd("touch", [tarball])
    :ok
  end

  def download!(project, tarball) do
    Logger.info("downloading tarball for #{project.name}")
    Logger.debug("url: #{project.recent_url}")
    Logger.debug("tarball: #{tarball}")

    {_, 0} = System.cmd("wget", ["-O", tarball, project.recent_url])
    Logger.debug("download complete")

    :ok
  end

  def decompress!(project, tarball) do
    Logger.info("decompressing tarball for #{project.name}")

    {paths, 0} = System.cmd("tar", ["tf", tarball])
    Logger.debug("paths=#{inspect(paths)}")

    dir =
      String.split(paths, "\n")
      |> List.first()
    Logger.debug("dir=#{inspect(dir)}")

    {xf, 0} = System.cmd("tar", ["xf", tarball, "--directory", @dirname])
    Logger.debug("xf=#{inspect(xf)}")

    Logger.debug("decompress tarball complete")
    Logger.debug("decompressing data csv")

    data_dir = Path.join(@dirname, dir)
    data_gz = Path.join(data_dir, "data.csv.gz")

    {_, 0} = System.cmd("gunzip", [data_gz])

    Logger.debug("decompress data csv complete")
    data_dir
  end

  def process_nodes_csv!(project, data_dir) do
    Logger.info("ripping #{project.slug}/nodes.csv")

    vsns2nodes =
      Nodes.list_nodes()
      |> Enum.map(& {&1.vsn, &1})
      |> Enum.into(%{})

    proj_nodes =
      Nodes.list_nodes(for_project: project.slug)
      |> Enum.map(& &1.vsn)
      |> MapSet.new()

    {:ok, _} =
      Path.join(data_dir, "nodes.csv")
      |> File.stream!()
      |> CSV.decode!(headers: true)
      |> Enum.reduce(Ecto.Multi.new(), fn row, multi ->
        vsn = row["vsn"]

        multi =
          case Map.get(vsns2nodes, vsn) do
            nil ->
              name = "insert node #{vsn}"
              Ecto.Multi.insert(multi, name, Node.changeset(%Node{}, node_params(row)))

            node ->
              name = "updating node #{vsn}"
              Ecto.Multi.update(multi, name, Node.changeset(node, node_params(row)))
          end

        case MapSet.member?(proj_nodes, vsn) do
          true ->
            multi

          false ->
            name = "insert projnode #{project.slug}/#{vsn}"
            Ecto.Multi.insert(multi, name, ProjectNode.changeset(%ProjectNode{}, %{project_slug: project.slug, node_vsn: vsn}))
        end
      end)
      |> Repo.transaction()

      :ok
  end

  def process_sensors_csv!(project, data_dir) do
    Logger.info("ripping #{project.slug}/sensors.csv")

    paths2sensors =
      Sensors.list_sensors()
      |> Enum.map(& {&1.path, &1})
      |> Enum.into(%{})

    {:ok, _} =
      Path.join(data_dir, "sensors.csv")
      |> File.stream!()
      |> CSV.decode!(headers: true)
      |> Enum.reduce(Ecto.Multi.new(), fn row, multi ->
        path = make_sensor_path(row)

        case Map.get(paths2sensors, path) do
          nil ->
            name = "insert sensor #{path}"
            Ecto.Multi.insert(multi, name, Sensor.changeset(%Sensor{}, sensor_params(row, path)))

          sensor ->
            name = "updating sensor #{path}"
            Ecto.Multi.update(multi, name, Sensor.changeset(sensor, sensor_params(row, path)))
        end
      end)
      |> Repo.transaction()

      :ok
  end

  def process_data_csv!(project, data_dir) do
    Logger.info("ripping #{project.slug}/data.csv")

    ids2nodes =
      Nodes.list_nodes()
      |> Enum.map(& {&1.id, &1})
      |> Enum.into(%{})

    paths2sensors =
      Sensors.list_sensors()
      |> Enum.map(& {&1.path, &1})
      |> Enum.into(%{})

    latest_observation =
      (from o in Observation, select: max(o.timestamp))
      |> Repo.one()

    async_opts = Application.get_env(:aot, :import_concurrency)

    Path.join(data_dir, "data.csv")
    |> File.stream!()
    |> DataCsv.parse_stream(headers: true)
    |> Stream.chunk_every(1_000)
    |> Task.async_stream(fn rows ->
      Logger.debug("processing csv chunk")

      headers = ~w(timestamp node_id subsystem sensor parameter value_raw value_hrf)

      {:ok, _} =
        rows
        |> Enum.reduce(Ecto.Multi.new(), fn raw_row, multi ->
          row = Enum.zip(headers, raw_row) |> Enum.into(%{})

          node_id = row["node_id"]
          sensor_path = make_sensor_path(row)
          timestamp = parse_ts(row["timestamp"])
          value = parse_value(row["value_hrf"])

          unless skip_node_id?(ids2nodes, node_id) or
            skip_sensor_path?(paths2sensors, sensor_path) or
            skip_timestamp?(timestamp, latest_observation) or
            is_nil(value)
          do
            node = Map.get(ids2nodes, node_id)
            sensor = Map.get(paths2sensors, sensor_path)
            name = "insert observation #{node.vsn}/#{sensor_path}/#{timestamp}"
            Ecto.Multi.insert(multi, name, Observation.changeset(%Observation{}, %{node_vsn: node.vsn, sensor_path: sensor_path, timestamp: timestamp, value: value, location: node.location, uom: sensor.uom}))
          else
            multi
          end
        end)
        |> Repo.transaction(timeout: :infinity)
    end, async_opts)
    |> Stream.run()

    :ok
  end

  def refresh_latest_observations!() do
    Logger.info("refreshing latest observations")

    Repo.query!("REFRESH MATERIALIZED VIEW latest_observations")

    :ok
  end

  def refresh_node_sensors!() do
    Logger.info("refreshing node sensors")

    Repo.query!("REFRESH MATERIALIZED VIEW node_sensors")

    :ok
  end

  def broadcast_latest!() do
    Logger.info("broadcasting latest observations to websockets")

    %Postgrex.Result{rows: rows} =
      Repo.query!("""
      SELECT
        node_vsn,
        json_agg(json_build_object(
          'sensor_path', sensor_path,
          'timestmap', timestamp,
          'value', value,
          'uom', uom)) AS observations
      FROM latest_observations
      GROUP BY node_vsn
      ORDER BY node_vsn ASC
      """)

    rows
    |> Enum.each(fn [vsn, observations] ->
      AotWeb.NodeChannel.broadcast_latest_observations(vsn, %{observations: observations})
    end)

    :ok
  end

  ##
  # helpers

  def node_params(row), do: %{
    vsn: row["vsn"],
    id: row["node_id"],
    lon: row["lon"],
    lat: row["lat"],
    description: row["description"],
    address: row["address"]
  }

  def make_sensor_path(row), do: "#{row["subsystem"]}.#{row["sensor"]}.#{row["parameter"]}"

  def sensor_params(row, path), do: %{
    path: path,
    uom: row["hrf_unit"],
    min: row["hrf_minval"],
    max: row["hrf_maxval"],
    data_sheet: row["datasheet"]
  }

  def parse_ts(""), do: nil
  def parse_ts(nil), do: nil
  def parse_ts(value), do: Timex.parse!(value, "%Y/%m/%d %H:%M:%S", :strftime)

  def skip_node_id?(ids2nodes, node_id) do
    case Map.has_key?(ids2nodes, node_id) do
      true -> false
      false ->
        Logger.debug("Unknown node id: #{node_id}")
        true
    end
  end

  def skip_sensor_path?(paths2sensors, sensor_path) do
    case Map.has_key?(paths2sensors, sensor_path) do
      true -> false
      false ->
        Logger.debug("Uknown sensor path: #{sensor_path}")
        true
    end
  end

  def skip_timestamp?(nil, _) do
    Logger.debug("Skipping row: missing timestamp")
    true
  end
  def skip_timestamp?(_, nil), do: false
  def skip_timestamp?(ts, latest) do
    case NaiveDateTime.compare(ts, latest) != :gt do
      false -> false
      true ->
        Logger.debug("Skipping row: timestamp too old")
        true
    end
  end

  def parse_value(""), do: nil
  def parse_value(nil), do: nil
  def parse_value(value) do
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
end
