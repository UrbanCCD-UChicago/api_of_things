defmodule AotWeb.ObservationPlugs do

  import AotWeb.ControllerUtils, only: [
    halt_with: 3
  ]

  import Plug.Conn, only: [
    assign: 3
  ]

  alias Plug.Conn

  @comp_regex ~r/^(lt|le|eq|ge|gt)\:[\d\.]+/i

  @no_op_agg_regex ~r/^first|last$/i

  @simple_agg_regex ~r/^(count|min|max|avg|sum|stddev|variance)\:[\w\s]+/i

  @perc_agg_regex ~r/^percentile\:[\d\.]+\:[\w\s]+/i

  @value_error "could not parse filter spec for `value`"

  @group_error "cannot group by given field"

  @doc """
  Parses the query params for a given key. If the key is found,
  the value is tested against a series of regexes to determine
  which ObservationQuery function applies. When matched, it is
  applied to the connection. If nothing matches it halts.
  """
  @spec value_funcs(Conn.t(), keyword()) :: Conn.t()
  def value_funcs(%Conn{params: %{"value" => filter}} = conn, opts) do
    groupers = opts[:groupers]

    cond do
      Regex.match?(@comp_regex, filter) ->
        [op, value] = String.split(filter, ":", parts: 2)
        assign(conn, :value, {String.to_atom(op), value})

      Regex.match?(@no_op_agg_regex, filter) ->
        assign(conn, :value, String.to_atom(filter))

      Regex.match?(@simple_agg_regex, filter) ->
        [op, grouper] = String.split(filter, ":", parts: 2)
        case Enum.member?(groupers, grouper) do
          true -> assign(conn, :value, {String.to_atom(op), String.to_atom(grouper)})
          false -> halt_with(conn, :unprocessable_entity, @group_error)
        end

      Regex.match?(@perc_agg_regex, filter) ->
        [op, perc, grouper] = String.split(filter, ":", parts: 3)
        case Enum.member?(groupers, grouper) do
          true -> assign(conn, :value, {String.to_atom(op), perc, String.to_atom(grouper)})
          false -> halt_with(conn, :unprocessable_entity, @group_error)
        end

      true ->
        halt_with(conn, :bad_request, @value_error)
    end
  end

  def value_funcs(conn, _opts), do: conn

  @hist_regex ~r/^[\d\.]+\:[\d\.]+\:[\d\.]+\:\w+/i

  @hist_error "histogram requires parameters as `min:max:count:group_by`"

  @doc """
  Parses and validates use of the `as_histogram` parameter.
  """
  @spec as_histogram(Conn.t(), keyword()) :: Conn.t()
  def as_histogram(%Conn{params: %{"as_histogram" => nil}} = conn, _opts),
    do: halt_with(conn, :bad_request, @hist_error)

    def as_histogram(%Conn{params: %{"as_histogram" => hist}} = conn, opts) do
    case Regex.match?(@hist_regex, hist) do
      false ->
        halt_with(conn, :bad_request, @hist_error)

      true ->
        [min, max, count, grouper] = String.split(hist, ":", parts: 4)
        case Enum.member?(opts[:groupers], grouper) do
          true -> assign(conn, :as_histogram, {min, max, count, String.to_atom(grouper)})
          false -> halt_with(conn, :unprocessable_entity, @group_error)
        end
    end
  end

  def as_histogram(conn, _opts), do: conn

  @tb_agg_regex ~r/^(count|min|max|avg|sum|stddev|variance)\:\d+\s(year|month|day|hour|minute|second)s?+/

  @tb_perc_regex ~r/^percentile\:[\d\.]+\:\d+\s(year|month|day|hour|minute|second)s?/

  @tb_error "time buckets require an aggregate function and postgres interval `func:n interval`"

  @doc """
  Parses and validates use of the `as_time_buckets` parameter.
  """
  @spec as_time_buckets(Conn.t(), keyword()) :: Conn.t()
  def as_time_buckets(%Conn{params: %{"as_time_buckets" => buckets}} = conn, _opts) do
    cond do
      Regex.match?(@tb_agg_regex, buckets) ->
        [func, interval] = String.split(buckets, ":", parts: 2)
        assign(conn, :as_time_buckets, {String.to_atom(func), interval})

      Regex.match?(@tb_perc_regex, buckets) ->
        [_, perc, interval] = String.split(buckets, ":", parts: 3)
        assign(conn, :as_time_buckets, {:percentile, perc, interval})

      true ->
        halt_with(conn, :bad_request, @tb_error)
    end
  end

  def as_time_buckets(conn, _opts), do: conn
end
