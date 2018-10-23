defmodule AotWeb.Schema.Types do
  use Absinthe.Schema.Notation
  import Absinthe.Resolution.Helpers
  alias Aot.Repo

  object :project do
    field :name, :string
    field :archive_url, :string
    field :recent_url, :string
    field :first_observation, :string
    field :latest_observation, :string
    field :bbox, :string
    field :hull, :string
    field :nodes, list_of(:node), resolve: dataloader(Repo)
    field :sensors, list_of(:sensor), resolve: dataloader(Repo)
  end

  object :node do
    field :id, :string
    field :location, :string
    field :latitude, :float
    field :longitude, :float
    field :description, :string
    field :address, :string
    field :commissioned_on, :string
    field :decommissioned_on, :string
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
    field :timestamp, :string
    field :value, :float
    field :node, :node, resolve: dataloader(Repo)
    field :sensor, :sensor, resolve: dataloader(Repo)
  end
end
