defmodule AotWeb.ObservationPlugs do

  import AotWeb.ControllerUtils, only: [
    halt_with: 3
  ]

  import Plug.Conn, only: [
    assign: 3
  ]

  alias Plug.Conn

  @comp_regex ~r/^lt|le|eq|ge|gt\:.+/i

  @no_op_agg_regex ~r/^first|last/i

  @simple_agg_regex ~r/^count|min|max|avg|sum|stddev|variance\:.+/i

  @perc_agg_regex ~r/^percentile\:.+\:.+/i

  @doc """
  Parses the query params for a given key. If the key is found,
  the value is tested against a series of regexes to determine
  which ObservationQuery function applies. When matched, it is
  applied to the connection. If nothing matches it halts.
  """
  @spec value_funcs(Conn.t(), keyword()) :: Conn.t()
  def value_funcs(conn, opts) do
    field = opts[:param]
    key = String.to_atom(field)

    case Map.get(conn.params, field) do
      nil ->
        conn

      filter ->
        cond do
          Regex.match?(@comp_regex, filter) ->
            [op, value] = String.split(filter, ":", parts: 2)
            assign(conn, key, {String.to_atom(op), value})

          Regex.match?(@no_op_agg_regex, filter) ->
            assign(conn, key, String.to_atom(filter))

          Regex.match?(@simple_agg_regex, filter) ->
            [op, grouper] = String.split(filter, ":", parts: 2)
            assign(conn, key, {String.to_atom(op), grouper})

          Regex.match?(@perc_agg_regex, filter) ->
            [op, perc, grouper] = String.split(filter, ":", parts: 3)
            assign(conn, key, {String.to_atom(op), perc, grouper})

          true ->
            halt_with(conn, :unprocessable_entity, "could not parse value for #{field}")
        end
    end
  end

  @hist_regex ~r/^.+\:.+\:.+\:.+/i

  @hist_error "histogram requires parameters as `min:max:count:group_by`"

  @doc """
  Parses and validates use of the `as_histogram` parameter.
  """
  @spec as_histogram(Conn.t(), keyword()) :: Conn.t()
  def as_histogram(%Conn{params: %{"as_histogram" => hist}} = conn, _opts) do
    case Regex.match?(@hist_regex, hist) do
      false ->
        halt_with(conn, :bad_request, @hist_error)

      true ->
        [min, max, count, grouper] = String.split(hist, ":", parts: 4)
        assign(conn, :as_histogram, {min, max, count, grouper})
    end
  end

  def as_histogram(conn, _opts), do: conn

  @tb_error "time buckets require an aggregate function and grouping field `func:field`"

  @doc """
  Parses and validates use of the `as_time_buckets` parameter.
  """
  @spec as_time_buckets(Conn.t(), keyword()) :: Conn.t()
  def as_time_buckets(%Conn{params: %{"as_time_buckets" => buckets}} = conn, _opts) do
    cond do
      Regex.match?(@simple_agg_regex, buckets) ->
        [func, grouper] = String.split(buckets, ":", parts: 2)
        assign(conn, :as_time_buckets, {String.to_atom(func), grouper})

      Regex.match?(@perc_agg_regex, buckets) ->
        [_, perc, grouper] = String.split(buckets, ":", parts: 3)
        assign(conn, :as_time_buckets, {:percentile, perc, grouper})

      true ->
        halt_with(conn, :bad_request, @tb_error)
    end
  end

  def as_time_buckets(conn, _opts), do: conn
end
