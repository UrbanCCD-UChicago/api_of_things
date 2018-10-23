defmodule AotWeb.Schema do
  use Absinthe.Schema
  import_types AotWeb.Schema.Types
  alias Aot.Repo
  alias AotWeb.Resolvers

  query do
    @desc "Get all projects"
    field :projects, list_of(:project) do
      resolve &Resolvers.list_projects/3
    end

    @desc "Get all nodes"
    field :nodes, list_of(:node) do
      resolve &Resolvers.list_nodes/3
    end

    @desc "Get all sensors"
    field :sensors, list_of(:sensor) do
      resolve &Resolvers.list_sensors/3
    end

    @desc "Get all observations"
    field :observations, list_of(:observation) do
      resolve &Resolvers.list_observations/3
    end
  end

  def context(ctx) do
    loader =
      Dataloader.new
      |> Dataloader.add_source(Repo, Repo.data())

    Map.put(ctx, :loader, loader)
  end

  def plugins do
    [Absinthe.Middleware.Dataloader] ++ Absinthe.Plugin.defaults()
  end
end
