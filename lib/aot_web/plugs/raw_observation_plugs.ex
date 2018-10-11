defmodule AotWeb.RawObservationPlugs do

  import AotWeb.ControllerUtils, only: [
    halt_with: 3
  ]

  import Plug.Conn, only: [
    assign: 3
  ]

  alias Plug.Conn

  @comp_regex ~r/^(lt|le|eq|ge|gt)\:[\d\.]+/i

  @no_op_agg_regex ~r/^first|last/i

  @simple_agg_regex ~r/^(count|min|max|avg|sum|stddev|variance)\:[\w\s]+/i

  @perc_agg_regex ~r/^percentile\:[\d\.]+\:[\w\s]+/i

  @comp_error "could not parse filter spec"

  @spec compare(Conn.t(), keyword()) :: Conn.t()
  def compare(conn, opts) do
    field = opts[:param]
    key = String.to_atom(field)

    case Map.get(conn.params, field) do
      nil ->
        conn

      filter ->
        case Regex.match?(@comp_regex, filter) do
          false ->
            halt_with(conn, :bad_request, @comp_error)

          true ->
            [op, value] = String.split(filter, ":", parts: 2)
            assign(conn, key, {String.to_atom(op), value})
        end
    end
  end

  @agg_error "could not parse value for aggregates"

  @group_error "cannot group by given field"

  @spec aggregates(Conn.t(), keyword()) :: Conn.t()
  def aggregates(%Conn{params: %{"aggregates" => aggs}} = conn, opts) do
    cond do
      Regex.match?(@no_op_agg_regex, aggs) ->
        assign(conn, :compute_aggs, String.to_atom(aggs))

      Regex.match?(@simple_agg_regex, aggs) ->
        [op, grouper] = String.split(aggs, ":", parts: 2)
        case Enum.member?(opts[:groupers], grouper) do
          true -> assign(conn, :compute_aggs, {String.to_atom(op), String.to_atom(grouper)})
          false -> halt_with(conn, :unprocessable_entity, @group_error)
        end

      Regex.match?(@perc_agg_regex, aggs) ->
        [op, perc, grouper] = String.split(aggs, ":", parts: 3)
        case Enum.member?(opts[:groupers], grouper) do
          true -> assign(conn, :compute_aggs, {String.to_atom(op), perc, String.to_atom(grouper)})
          false -> halt_with(conn, :unprocessable_entity, @group_error)
        end

      true ->
        halt_with(conn, :bad_request, @agg_error)
    end
  end

  def aggregates(conn, _opts), do: conn

  @hist_regex ~r/^[\d\.]+\:[\d\.]+\:[\d\.]+\:[\d\.]+\:\d+\:\w+/i

  @hist_error "histogram requires parameters as `raw_min:raw_max:hrf_min:hrf_max:count:group_by`"

  @doc """
  Parses and validates use of the `as_histogram` parameter.
  """
  @spec as_histograms(Conn.t(), keyword()) :: Conn.t()
  def as_histograms(%Conn{params: %{"as_histograms" => hist}} = conn, opts) do
    case Regex.match?(@hist_regex, hist) do
      false ->
        halt_with(conn, :bad_request, @hist_error)

      true ->
        [raw_min, raw_max, hrf_min, hrf_max, count, grouper] = String.split(hist, ":", parts: 6)
        case Enum.member?(opts[:groupers], grouper) do
          true -> assign(conn, :as_histograms, {raw_min, raw_max, hrf_min, hrf_max, count, String.to_atom(grouper)})
          false -> halt_with(conn, :unprocessable_entity, @group_error)
        end
    end
  end

  def as_histograms(conn, _opts), do: conn
end
