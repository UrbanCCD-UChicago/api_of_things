defmodule Aot.M2MActions do
  @moduledoc """
  The internal API for creating new M2M records.
  """

  import Aot.ActionUtils

  alias Aot.{
    ProjectNode,
    ProjectSensor,
    NodeSensor,
    Repo
  }

  @doc """
  Creates a new M2M record for the relationship between Projects and Nodes.
  """
  @spec create_project_node(keyword() | map()) :: {:ok, ProjectNode.t()}
  def create_project_node(params) do
    params =
      params
      |> atomize()
      |> parse_relation(:project, :slug)
      |> parse_relation(:node, :id)

    ProjectNode.changeset(%ProjectNode{}, params)
    |> Repo.insert(on_conflict: :nothing)
  end

  @doc """
  Creates a new M2M record for the relationship between Projects and Sensors.
  """
  @spec create_project_sensor(keyword() | map()) :: {:ok, ProjectSensor.t()}
  def create_project_sensor(params) do
    params =
      params
      |> atomize()
      |> parse_relation(:project, :slug)
      |> parse_relation(:sensor, :path)

    ProjectSensor.changeset(%ProjectSensor{}, params)
    |> Repo.insert(on_conflict: :nothing)
  end

  @doc """
  Creates a new M2M record for the relationship between Nodes and Sensors.
  """
  @spec create_node_sensor(keyword() | map()) :: {:ok, NodeSensor.t()}
  def create_node_sensor(params) do
    params =
      params
      |> atomize()
      |> parse_relation(:node, :id)
      |> parse_relation(:sensor, :path)

    NodeSensor.changeset(%NodeSensor{}, params)
    |> Repo.insert(on_conflict: :nothing)
  end
end
