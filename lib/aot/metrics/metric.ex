defmodule Aot.Metrics.Metric do
  @moduledoc ""

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "metrics" do
    field :timestamp, :naive_datetime
    field :value, :float
    field :location, Geo.PostGIS.Geometry
    field :uom, :string

    belongs_to :node, Aot.Nodes.Node,
      foreign_key: :node_vsn,
      references: :vsn,
      type: :string

    belongs_to :sensor, Aot.Sensors.Sensor,
      foreign_key: :sensor_path,
      references: :path,
      type: :string
  end

  @attrs ~w| node_vsn sensor_path timestamp value location uom |a
  @reqd ~w| node_vsn sensor_path timestamp value location |a

  @doc false
  def changeset(metric, attrs) do
    metric
    |> cast(attrs, @attrs)
    |> validate_required(@reqd)
    |> foreign_key_constraint(:node)
    |> foreign_key_constraint(:sensor)
    |> unique_constraint(:timestamp, name: :metrics_uniq)
  end
end
