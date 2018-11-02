defmodule AotWeb.Schema.Types do
  use Absinthe.Schema.Notation
  import Absinthe.Resolution.Helpers
  alias Aot.Repo

  object :project do
    field :name, :string
    field :archive_url, :string
    field :recent_url, :string
    field :first_observation, :naive_datetime
    field :latest_observation, :naive_datetime
    field :bbox, :string
    field :hull, :string
    field :nodes, list_of(:node), resolve: dataloader(Repo)
    field :sensors, list_of(:sensor), resolve: dataloader(Repo)
  end

  object :node do
    field :vsn, :string
    field :location, :string
    field :latitude, :float
    field :longitude, :float
    field :description, :string
    field :address, :string
    field :commissioned_on, :naive_datetime
    field :decommissioned_on, :naive_datetime
    field :projects, list_of(:project), resolve: dataloader(Repo)
    field :sensors, list_of(:sensor), resolve: dataloader(Repo)
    field :observations, list_of(:observation), resolve: dataloader(Repo)
  end

  object :sensor do
    field :ontology, :string
    field :subsystem, :string
    field :sensor, :string
    field :parameter, :string
    field :uom, :string
    field :min, :float
    field :max, :float
    field :data_sheet, :string
    field :nodes, list_of(:node), resolve: dataloader(Repo)
    field :projects, list_of(:project), resolve: dataloader(Repo)
    field :observations, list_of(:observation), resolve: dataloader(Repo)
  end

  object :observation do
    field :timestamp, :naive_datetime
    field :value, :float
    field :node, :node, resolve: dataloader(Repo)
    field :sensor, :sensor, resolve: dataloader(Repo)
  end

  input_object :float_query do
    field :lt, :float
    field :le, :float
    field :gt, :float
    field :ge, :float
    field :eq, :float
  end

  input_object :string_query do
    field :like, :string
  end

  input_object :naive_datetime_query do
    field :lt, :naive_datetime
    field :le, :naive_datetime
    field :gt, :naive_datetime
    field :ge, :naive_datetime
    field :eq, :naive_datetime
  end

  input_object :geojson_polygon do
    field :srid, :integer
    field :coordinates, list_of(list_of(list_of(:float)))
  end

  input_object :geojson_point do
    field :srid, :integer
    field :coordinates, list_of(:float)
  end
end
