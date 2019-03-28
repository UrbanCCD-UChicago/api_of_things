defmodule AotWeb.NodeChannel do
  use AotWeb, :channel
  alias Aot.{Nodes, Repo}

  def join("nodes:" <> vsn, _, socket) do
    case Nodes.get_node(vsn) do
      {:error, _} ->
        {:error, %{reason: "Node #{vsn} not found"}}

      {:ok, node} ->
        qres = Repo.query("""
          SELECT
            node_vsn,
            json_agg(json_build_object(
              'sensor_path', sensor_path,
              'timestamp', timestamp,
              'value', value,
              'uom', uom)) AS observations
          FROM latest_observations
          WHERE node_vsn = '#{node.vsn}'
          GROUP BY node_vsn
          ORDER BY node_vsn ASC
          """)

        case qres do
          {:ok, %Postgrex.Result{rows: [[_, observations]]}} ->
            {:ok, %{observations: observations}, socket}

          _ ->
            {:error, %{reason: "Node #{vsn} not currently streaming observations"}}
        end
    end
  end

  def handle_out(event, payload, socket) do
    push(socket, event, payload)
    {:noreply, socket}
  end

  def broadcast_latest_observations(vsn, observations),
    do: AotWeb.Endpoint.broadcast("nodes:#{vsn}", "latest", observations)
end
