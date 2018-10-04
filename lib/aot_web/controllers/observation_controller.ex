defmodule AotWeb.ObservationController do
  use AotWeb, :controller

  import Aot.ControllerUtils, only: [ halt_with: 3 ]

  import Aot.Plugs

  import Plug.Conn, only: [ assign: 3 ]

  alias Aot.ObservationActions

  alias Plug.Conn

  # controller specific plugs

  def obs_include_node(%Conn{params: %{"include_node" => nodes?}} = conn, _opts),
    do: if nodes?, do: assign(conn, :include_node, true), else: conn

  def obs_include_node(conn, _opts), do: conn

  def obs_include_sensor(%Conn{params: %{"include_sensor" => sensors?}} = conn, _opts),
    do: if sensors?, do: assign(conn, :include_sensors, true), else: conn

  def obs_include_sensor(conn, _opts), do: conn

  @ops ~W( between eq ge gt le lt )
  @aggs ~W( avg count first last max min stddev sum variance percentile )
  @split_value ~W( between percentile )
  @value_error "cannot parse value comparison operator"
  @split_error "using a range operator requires the filter value to have 2 elements separated with a comma"

  def obs_value_operation(%Conn{params: %{"value" => value}} = conn, _opts) do
    op_value = String.split(value, ":", parts: 2)
    do_value_operation(op_value, conn)
  end

  def obs_value_operation(conn, _opts), do: conn

  defp do_value_operation([value_only], conn), do: do_value_operation(["eq", value_only], conn)

  defp do_value_operation([op, value], conn) do
    cond do
      Enum.member?(@ops, op) -> do_ops(op, value, conn)
      Enum.member?(@aggs, op) -> do_aggs(op, value, conn)
      true -> halt_with(conn, :bad_request, @value_error)
    end
  end

  defp do_ops(op, value, conn) when op in @split_value do
    try do
      [lo, hi] = String.split(value, ",", parts: 2)
      assign(conn, :value_op, {String.to_atom(op), {lo, hi}})

    rescue
      MatchError ->
        halt_with(conn, :bad_request, @split_error)
    end
  end

  defp do_ops(op, value, conn), do: assign(conn, :value_op, {String.to_atom(op), value})

  defp do_aggs(op, value, conn) when op in @split_value do
    try do
      [lo, hi] = String.split(value, ",", parts: 2)
      assign(conn, :value_agg, {String.to_atom(op), {lo, hi}})

    rescue
      MatchError ->
        halt_with(conn, :bad_request, @split_error)
    end
  end

  defp do_aggs(op, value, conn), do: assign(conn, :value_op, {String.to_atom(op), value})

  @hist_error "using the `histogram` parameter requires the value to be a comma separated list of min, max, number of buckets, and grouping field name"

  def obs_as_histogram(%Conn{params: %{"histogram" => args}} = conn, _opts) do
    try do
      [min, max, num_buckets, group] = String.split(args, ",")
      assign(conn, :as_histogram, {min, max, num_buckets, String.to_atom(group)})

    rescue
      MatchError ->
        halt_with(conn, :bad_request, @hist_error)
    end
  end

  def obs_as_histogram(conn, _opts), do: conn

  @tb_error "could not parse value for `time_buckets`"

  def obs_as_time_buckets(%Conn{params: %{"time_buckets" => args}} = conn, _opts) do
    try do
      [agg, interval] = String.split(args, ":", parts: 2)
      interval =
        case agg do
          "percentile" -> String.split(interval, ",", parts: 2) |> List.to_tuple()
          _ -> interval
        end

      assign(conn, :as_time_buckets, {String.to_atom(agg), interval})

    rescue
      MatchError ->
        halt_with(conn, :bad_request, @tb_error)
    end
  end

  def obs_as_time_buckets(conn, _opts), do: conn

  def obs_validate_order_by(%Conn{params: %{"time_bucket" => _, "order_by" => _}} = conn, _opts),
    do: halt_with(conn, :bad_request, "cannot specify ordering when using the `time_bucket` parameter")

  def obs_validate_order_by(conn, _opts), do: conn

  # inline plugs

  plug :obs_include_node
  plug :obs_include_sensor
  plug :include_networks
  plug :for_related, func: :for_network
  plug :for_related, func: :for_node
  plug :for_related, func: :for_sensor
  plug :geom_field, field: "location", func_map: %{"within" => :located_within, "proximity" => :within_distance}
  plug :timestamp_op, field: "timestamp", func: :timestamp_op
  plug :obs_value_operation
  plug :obs_as_histogram
  plug :obs_as_time_buckets
  plug :obs_validate_order_by
  plug :order_by, default: "desc:timestamp"
  plug :validate_page
  plug :validate_size
  plug :paginate

  def index(conn, _params) do
    observations = ObservationActions.list(Map.to_list(conn.assigns))
    render(conn, "index.json", observations: observations)
  end
end
