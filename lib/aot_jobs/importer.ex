defmodule AotJobs.Importer do
  require Logger
  import Ecto.Query
  alias Aot.{Nodes, Projects, Repo, Sensors}
  alias Aot.M2m.ProjectNode
  alias Aot.Metrics.Metric
  alias Aot.Nodes.Node
  alias Aot.Observations.Observation
  alias Aot.Projects.Project
  alias Aot.Sensors.Sensor
  alias NimbleCSV.RFC4180, as: CSV

  @temp_dirname "/tmp/aot-tarballs"

  @doc """
  The run function will scrape the AoT downloads page from projects,
  ensure the projects exist, and then download the recent tarballs and
  process them.

  This function is useful for automated runs using the scheduler. For
  one off jobs, use the `process_project` function with a `Project`
  record parameter.
  """
  @spec run() :: :ok
  def run do
    scrape_downloads_page()
    |> ensure_projects()
    |> Enum.each(&process_project/1)
  end

  @doc """
  This function will download the recent tarball for the given project
  and process its metadata and data files.
  """
  @spec process_project(Project.t()) :: :ok
  def process_project(%Project{} = project) do
    # get the download path
    file_name = String.split(project.recent_url, "/") |> List.last()
    tarball_path = "#{@temp_dirname}/#{file_name}"

    # ensure a clean path
    if File.exists?(@temp_dirname), do: System.cmd "rm", ["-rf", @temp_dirname]
    System.cmd "mkdir", ["-p", @temp_dirname]
    System.cmd "touch", [tarball_path]

    # download the tarball
    Logger.info("Downloading #{project.recent_url}")
    System.cmd "wget", ["-O", tarball_path, project.recent_url]

    # decompress tarball
    Logger.info("Decompressing #{tarball_path}")
    # get the list of extracted paths -- save the top level dirname
    {paths, 0} = System.cmd "tar", ["tf", tarball_path]
    dir = String.split(paths, "\n") |> List.first()
    # decompress tarball
    {_, 0} = System.cmd "tar", ["xf", tarball_path, "--directory", @temp_dirname]
    # build the path to the extracted dirname
    extracted_dirname = "#{@temp_dirname}/#{dir}"
    # gunzip the data csv
    {_, 0} = System.cmd "gunzip", ["#{extracted_dirname}/data.csv.gz"]

    # process nodes.csv
    Logger.info("Ripping #{project.slug}/nodes.csv")
    nodes =
      Nodes.list_nodes()
      |> Enum.map(& {&1.vsn, &1})
      |> Enum.into(%{})

    project_nodes =
      Nodes.list_nodes(for_project: project.slug)
      |> Enum.map(& &1.vsn)
      |> MapSet.new()

    {nodes_multi, _} =
      "#{extracted_dirname}/nodes.csv"
      |> File.stream!()
      |> CSV.parse_stream(headers: true)
      |> Enum.reduce({Ecto.Multi.new(), MapSet.new()}, fn [node_id, _, vsn, address, lat, lon, description, _, _], {multi, seen_vsns} ->
        case MapSet.member?(seen_vsns, vsn) do
          true ->
            Logger.warn("Duplicate VSN #{vsn} in #{project.name} nodes.csv")
            {multi, seen_vsns}

          false ->
            seen_vsns = MapSet.put(seen_vsns, vsn)
            # insert/update node
            multi = case Map.get(nodes, vsn) do
              nil ->
                name = "insert node #{vsn}"
                Ecto.Multi.insert(multi, name, Node.changeset(%Node{}, %{id: node_id, vsn: vsn, address: address, lat: lat, lon: lon, description: description}))

              node ->
                name = "update node #{vsn}"
                Ecto.Multi.update(multi, name, Node.changeset(node, %{id: node_id, vsn: vsn, address: address, lat: lat, lon: lon, description: description}))
            end
            # insert project-node m2m
            multi = case MapSet.member?(project_nodes, vsn) do
              true ->
                multi

              false ->
                name = "insert project/node #{project.slug}/#{vsn}"
                Ecto.Multi.insert(multi, name, ProjectNode.changeset(%ProjectNode{}, %{project_slug: project.slug, node_vsn: vsn}))
            end
            # done
            {multi, seen_vsns}
        end
      end)

    Repo.transaction(nodes_multi)

    # process sensors.csv
    Logger.info("Ripping #{project.slug}/sensors.csv")
    sensors =
      Sensors.list_sensors()
      |> Enum.map(& {&1.path, &1})
      |> Enum.into(%{})

    {sensors_multi, _} =
      "#{extracted_dirname}/sensors.csv"
      |> File.stream!()
      |> CSV.parse_stream(headers: true)
      |> Enum.reduce({Ecto.Multi.new(), MapSet.new()}, fn [_, subsystem, sensor, parameter, uom, min, max, ds], {multi, seen_sensors} ->
        path = "#{subsystem}.#{sensor}.#{parameter}"
        case MapSet.member?(seen_sensors, path) do
          true ->
            Logger.warn("Duplicate sensor #{path} in #{project.name} sensors.csv")
            {multi, seen_sensors}

          false ->
            seen_sensors = MapSet.put(seen_sensors, path)
            # insert or update
            multi = case Map.get(sensors, path) do
              nil ->
                name = "insert sensor #{path}"
                Ecto.Multi.insert(multi, name, Sensor.changeset(%Sensor{}, %{path: path, data_sheet: ds, uom: uom, min: min, max: max}))

              sensor ->
                name = "update sensor #{path}"
                Ecto.Multi.update(multi, name, Sensor.changeset(sensor, %{path: path, data_sheet: ds, uom: uom, min: min, max: max}))
            end
            # done
            {multi, seen_sensors}
        end
      end)

    Repo.transaction(sensors_multi)

    # process data.csv
    Logger.info("Ripping #{project.slug}/data.csv")

    nodes =
      Nodes.list_nodes()
      |> Enum.map(& {&1.id, &1})
      |> Enum.into(%{})

    sensors =
      Sensors.list_sensors()
      |> Enum.map(& {&1.path, &1})
      |> Enum.into(%{})

    latest_observation = Repo.one(
      from o in Observation,
      left_join: p in ProjectNode, on: o.node_vsn == p.node_vsn,
      where: p.project_slug == ^project.slug,
      select: max(o.timestamp)
    )

    latest_metric = Repo.one(
      from m in Metric,
      left_join: p in ProjectNode, on: m.node_vsn == p.node_vsn,
      where: p.project_slug == ^project.slug,
      select: max(m.timestamp)
    )

    async_opts = Application.get_env(:aot, :import_concurrency)

    "#{extracted_dirname}/data.csv"
    |> File.stream!()
    |> CSV.parse_stream(headers: true)
    |> Stream.chunk_every(5_000)
    |> Task.async_stream(fn rows ->
      {multi, _} = Enum.reduce(rows, {Ecto.Multi.new(), MapSet.new()}, fn [timestamp, node_id, subsystem, sensor, param, _, value], {multi, seen_rows} ->
        path = "#{subsystem}.#{sensor}.#{param}"
        sensor = Map.get(sensors, path)
        if is_nil(sensor), do: Logger.warn("Unknown sensor #{path} in #{project.name} data.csv")

        node = Map.get(nodes, node_id)
        if is_nil(node), do: Logger.warn("Unknown node #{node_id} in #{project.name} data.csv")

        timestamp = case timestamp do
          "" -> nil
          _ -> Timex.parse!(timestamp, "%Y/%m/%d %H:%M:%S", :strftime)
        end

        row_id = "#{node.vsn}/#{path}/#{timestamp}"

        value = case value do
          "" ->
            nil

          _ ->
            case Regex.match?(~r/^[0-9\.\-]+$/, value) do
              true ->
                value

              false ->
                Logger.warn("Non-float value #{value} for row #{row_id} in #{project.name} data.csv")
                nil
            end
        end

        case MapSet.member?(seen_rows, row_id) do
          true ->
            Logger.warn("Dupliecate row #{row_id} in #{project.name} data.csv")
            {multi, seen_rows}

          false ->
            seen_rows = MapSet.put(seen_rows, row_id)
            multi =
              unless is_nil(node) or is_nil(sensor) or is_nil(timestamp) or is_nil(value) do
                case subsystem == "ep" or subsystem == "nc" or subsystem == "wagman" do
                  true ->
                    case ndtcmp(timestamp, latest_metric) == :gt do
                      false ->
                        multi

                      true ->
                        name = "insert metric #{row_id}"
                        Ecto.Multi.insert(multi, name, Metric.changeset(%Metric{}, %{
                          node_vsn: node.vsn, sensor_path: path, timestamp: timestamp, value: value, location: node.location, uom: sensor.uom}))
                    end

                  false ->
                    case ndtcmp(timestamp, latest_observation) == :gt do
                      false ->
                        multi

                      true ->
                        name = "insert observation #{row_id}"
                        Ecto.Multi.insert(multi, name, Observation.changeset(%Observation{}, %{
                          node_vsn: node.vsn, sensor_path: path, timestamp: timestamp, value: value, location: node.location, uom: sensor.uom}))
                    end
                end
              else
                multi
              end

            {multi, seen_rows}
        end
      end)

      Repo.transaction(multi, timeout: :infinity)
    end, async_opts)
    |> Stream.run()

    :ok
  after
    Logger.info("Cleaning up #{@temp_dirname}")
    System.cmd "rm", ["-rf", @temp_dirname]

    :ok
  end

  #
  # parses the aot downloads page and returns a list of {name, recent tarball url}
  defp scrape_downloads_page do
    Logger.info("Scraping AoT downloads page for projects")

    %HTTPoison.Response{body: body} = HTTPoison.get!("https://www.mcs.anl.gov/research/projects/waggle/downloads/datasets/index.php")

    urls =
      body
      |> String.split(" ")
      |> Enum.filter(fn x -> Regex.match?(~r".*complete\.recent\.tar", x) end)
      |> Enum.map(fn x -> String.replace(x, "</a>", "") end)
      |> Enum.map(fn x -> String.replace(x, "href='", "") end)
      |> Enum.map( fn x -> String.split(x, "'") |> List.first() end)

    names =
      urls
      |> Enum.map(fn x -> String.split(x, "/") |> List.last() end)
      |> Enum.map(fn x -> String.replace(x, ".complete.recent.tar", "") end)
      |> Enum.map(fn x -> String.replace(x, "AoT_", "") end)
      |> Enum.map(fn x -> String.replace(x, "_", " ") end)

    # return {name, url}
    Enum.zip names, urls
  end

  #
  # given a list of {name, url} this will either lookup or create a project
  defp ensure_projects(names_and_urls) do
    names_and_urls
    |> Enum.map(fn {name, url} ->
      case Repo.one(from p in Project, where: p.recent_url == ^url) do
        nil ->
          Logger.info("Creating new project for #{name}")
          archive = String.replace(url, "recent", "latest")
          {:ok, proj} = Projects.create_project(%{name: name, recent_url: url, archive_url: archive})
          proj

        found ->
          found
        end
    end)
  end

  defp ndtcmp(_, nil), do: :gt
  defp ndtcmp(left, right), do: NaiveDateTime.compare(left, right)
end
