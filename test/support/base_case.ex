defmodule Aot.Testing.BaseCase do
  use ExUnit.CaseTemplate

  alias Aot.{
    M2MActions,
    NetworkActions,
    NodeActions,
    ObservationActions,
    RawObservationActions,
    SensorActions
  }

  setup_all tags do
    # sandbox the repo
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Aot.Repo)
    unless tags[:async] do
      :ok = Ecto.Adapters.SQL.Sandbox.mode(Aot.Repo, {:shared, self()})
    end

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

    :ok
  end

  setup tags do
    context = []
    add2ctx = tags[:add2ctx] || []
    add2ctx =
      case is_list(add2ctx) do
        true -> add2ctx
        false -> [add2ctx]
      end

    # add networks to context?
    context =
      case :networks in add2ctx do
        false ->
          context

        true ->
          NetworkActions.list()
          |> Enum.map(& {String.to_atom(String.replace(&1.slug, "-", "_")), &1})
          |> Keyword.merge(context)
      end

    # add nodes to context?
    context =
      case :nodes in add2ctx do
        false ->
          context

        true ->
          NodeActions.list()
          |> Enum.map(& {:"n#{&1.vsn}", &1})
          |> Keyword.merge(context)
      end

    # add sensors to context?
    context =
      case :sensors in add2ctx do
        false ->
          context

        true ->
          SensorActions.list()
          |> Enum.map(& {:"s#{&1.id}", &1})
          |> Keyword.merge(context)
      end

    # return the context
    {:ok, context}
  end
end
