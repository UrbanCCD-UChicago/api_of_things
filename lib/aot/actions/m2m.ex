defmodule Aot.M2MActions do
  @moduledoc """
  The internal API for creating new M2M records.
  """

  import Aot.ActionUtils

  alias Aot.{
    NetworkNode,
    NetworkSensor,
    NodeSensor,
    Repo
  }

  @doc """
  Creates a new M2M record for the relationship between Networks and Nodes.
  """
  def create_network_node(params) do
    params =
      params
      |> atomize()
      |> parse_rel(:network)
      |> parse_rel(:node)

    NetworkNode.changeset(%NetworkNode{}, params)
    |> Repo.insert(on_conflict: :nothing)
  end

  @doc """
  Creates a new M2M record for the relationship between Networks and Sensors.
  """
  def create_network_sensor(params) do
    params =
      params
      |> atomize()
      |> parse_rel(:network)
      |> parse_rel(:sensor)

    NetworkSensor.changeset(%NetworkSensor{}, params)
    |> Repo.insert(on_conflict: :nothing)
  end

  @doc """
  Creates a new M2M record for the relationship between Nodes and Sensors.
  """
  def create_node_sensor(params) do
    params =
      params
      |> atomize()
      |> parse_rel(:node)
      |> parse_rel(:sensor)

    NodeSensor.changeset(%NodeSensor{}, params)
    |> Repo.insert(on_conflict: :nothing)
  end
end
