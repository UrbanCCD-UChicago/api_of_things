defmodule Aot.Sensor do
  @moduledoc """
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias Aot.{
    Network,
    NetworkSensor,
    Node,
    NodeSensor,
    RawObservation,
    Observation
  }

  schema "sensors" do
    # path
    field :ontology, :string
    field :subsystem, :string
    field :sensor, :string
    field :parameter, :string

    # the path field is the dotted join of subsystem, sensor and parameter
    # it's there so we can provide a string id for the sensor and be able
    # to do observations ops like ``metsense.htu21d.temperature > 30``.
    field :path, :string

    # cleaned value's unit of measurement
    field :unit, :string, default: nil

    # reverse relationships
    has_many :observations, Observation
    has_many :raw_observations, RawObservation
    many_to_many :networks, Network, join_through: NetworkSensor
    many_to_many :nodes, Node, join_through: NodeSensor
  end

  @attrs ~W( ontology subsystem sensor parameter  unit ) |> Enum.map(&String.to_atom/1)
  @reqd ~W( ontology subsystem sensor parameter ) |> Enum.map(&String.to_atom/1)
  @uniq "the set of {subsystem, sensor, parameter} has already been taken"

  @doc false
  def changeset(sensor, attrs) do
    sensor
    |> cast(attrs, @attrs)
    |> validate_required(@reqd)
    |> unique_constraint(:subsystem, name: :sensors_ssp, message: @uniq)
    |> put_path()
  end

  defp put_path(%Ecto.Changeset{valid?: true} = cs) do
    sub_change = get_change(cs, :subsystem)
    sen_change = get_change(cs, :sensor)
    param_change = get_change(cs, :parameter)

    case !is_nil(sub_change) or !is_nil(sen_change) or !is_nil(param_change) do
      false ->
        cs

      true ->
        subsystem = get_field(cs, :subsystem)
        sensor = get_field(cs, :sensor)
        parameter = get_field(cs, :parameter)

        path = "#{subsystem}.#{sensor}.#{parameter}"
        put_change(cs, :path, path)
    end
  end

  defp put_path(cs), do: cs
end
