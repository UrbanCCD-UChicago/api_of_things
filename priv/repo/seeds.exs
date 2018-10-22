alias Aot.{ProjectActions, NodeActions, SensorActions, ObservationActions}

try do
  {:ok, _} =
    ProjectActions.create name: "Chicago",
      archive_url: "https://www.mcs.anl.gov/research/projects/waggle/downloads/datasets/AoT_Chicago.complete.latest.tar",
      recent_url: "https://www.mcs.anl.gov/research/projects/waggle/downloads/datasets/AoT_Chicago.complete.recent.tar"
rescue
  error in Ecto.ConstraintError ->
    IO.inspect(error)
end

try do
  {:ok, _} =
    NodeActions.create(
      id: "0x00000000",
      vsn: "0",
      latitude: 0.0,
      longitude: 0.0,
      commissioned_on: ~N[2000-01-01 00:00:00],
    )
rescue
  error in MatchError ->
    IO.inspect(error)
end

try do
  {:ok, _} =
    SensorActions.create(
      ontology: "ontology",
      subsystem: "subsystem",
      sensor: "sensor",
      parameter: "parameter",
    )
rescue
  error in MatchError ->
    IO.inspect(error)
end

try do
  {:ok, _} =
    ObservationActions.create(
      node_vsn: "0",
      sensor_path: "subsystem.sensor.parameter",
      timestamp: ~N[2000-01-01 00:00:00],
      value: 0.0
    )
rescue
  error in MatchError ->
    IO.inspect(error)
end
