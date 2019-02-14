defmodule AotWeb.ObservationPlugs do
  @moduledoc ""

  import AotWeb.ControllerUtils, only: [halt_with: 2]
  import Plug.Conn, only: [assign: 3]
  alias Plug.Conn

  def timestamp(%Conn{params: %{"timestamp" => op_stamp}} = conn, _) do
    [op, timestamp] = String.split(op_stamp, ":", parts: 2)

    cond do
      Enum.member?(~w(lt le eq ge gt), op) ->
        assign(conn, :timestamp, [op, timestamp])

      op == "between" ->
        [starts, ends] = String.split(timestamp, "::", parts: 2)
        assign(conn, :timestamp, [op, starts, ends])

      true ->
        halt_with(conn, 400)
    end
  end

  def timestamp(conn, _), do: conn

  def value(%Conn{params: %{"value" => op_stamp}} = conn, _) do
    [op, value] = String.split(op_stamp, ":", parts: 2)

    cond do
      Enum.member?(~w(lt le eq ge gt), op) ->
        assign(conn, :value, [op, value])

      op == "between" ->
        [starts, ends] = String.split(value, "::", parts: 2)
        assign(conn, :value, [op, starts, ends])

      true ->
        halt_with(conn, 400)
    end
  end

  def value(conn, _), do: conn

  def histogram(%Conn{params: %{"histogram" => histogram}} = conn, _) do
    [min, max, count] = String.split(histogram, "::", parts: 3)

    assign(conn, :histogram, [min, max, count])
  end

  def histogram(conn, _), do: conn

  def time_bucket(%Conn{params: %{"time_bucket" => time_bucket}} = conn, _) do
    [func, interval] = String.split(time_bucket, ":", parts: 2)

    case Enum.member?(~w(min max avg median), func) do
      true -> assign(conn, :time_bucket, [func, interval])
      false -> halt_with(conn, 400)
    end
  end

  def time_bucket(conn, _), do: conn
end
