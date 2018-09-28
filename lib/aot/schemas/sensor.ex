defmodule Aot.Sensor do
  @moduledoc """
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias Aot.{
    Network,
    Node,
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
    many_to_many :networks, Network, join_through: "networks_sensors"
    many_to_many :nodes, Node, join_through: "nodes_sensors"
  end

  @attrs ~W( ontology subsystem sensor parameter  unit ) |> Enum.map(&String.to_atom/1)
  @reqd ~W( ontology subsystem sensor parameter ) |> Enum.map(&String.to_atom/1)

  @doc false
  def changeset(sensor, attrs) do
    sensor
    |> cast(attrs, @attrs)
    |> validate_required(@reqd)
  end
end
