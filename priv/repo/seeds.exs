alias Aot.{
  M2MActions,
  NetworkActions,
  NodeActions,
  ObservationActions,
  RawObservationActions,
  SensorActions
}

# load networks
"test/fixtures/networks.csv"
|> File.stream!()
|> CSV.decode!(headers: true)
|> Enum.each(&NetworkActions.create/1)

# load nodes
"test/fixtures/nodes.csv"
|> File.stream!()
|> CSV.decode!(headers: true)
|> Enum.each(&NodeActions.create/1)

# load sensors
"test/fixtures/sensors.csv"
|> File.stream!()
|> CSV.decode!(headers: true)
|> Enum.each(&SensorActions.create/1)

# load observations
"test/fixtures/data.csv"
|> File.stream!()
|> CSV.decode!(headers: true)
|> Enum.reject(& &1["value"] == nil)
|> Enum.each(&ObservationActions.create/1)

# load raw observations
"test/fixtures/data.csv"
|> File.stream!()
|> CSV.decode!(headers: true)
|> Enum.reject(& &1["raw"] == nil)
|> Enum.map(& Map.put(&1, :hrf, &1["value"]))
|> Enum.each(&RawObservationActions.create/1)

# load node/sensor m2m
"test/fixtures/nos.csv"
|> File.stream!()
|> CSV.decode!(headers: true)
|> Enum.each(&M2MActions.create_node_sensor/1)

# load network/node m2m
"test/fixtures/nn.csv"
|> File.stream!()
|> CSV.decode!(headers: true)
|> Enum.each(&M2MActions.create_network_node/1)

# load network/sensor m2m
"test/fixtures/ns.csv"
|> File.stream!()
|> CSV.decode!(headers: true)
|> Enum.each(&M2MActions.create_network_sensor/1)

# update network bbox and hull
NetworkActions.list()
|> Enum.each(fn network ->
  bbox = NetworkActions.compute_bbox(network)
  hull = NetworkActions.compute_hull(network)
  {:ok, _} = NetworkActions.update(network, bbox: bbox, hull: hull)
end)
