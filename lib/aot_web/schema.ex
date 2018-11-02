defmodule AotWeb.Schema do
  use Absinthe.Schema
  import_types(AotWeb.Schema.Types)
  import_types(Absinthe.Type.Custom)
  alias Aot.Repo
  alias AotWeb.Resolvers

  query do
    @desc "Get all projects"
    field :projects, list_of(:project) do
      arg(:intersects, :geojson_polygon)
      arg(:contains, :geojson_point)
      resolve(&Resolvers.list_projects/3)
    end

    @desc "Get all nodes"
    field :nodes, list_of(:node) do
      arg(:within, :geojson_polygon)
      arg(:alive, :boolean)
      arg(:commissioned_on, :naive_datetime_query)
      arg(:decommissioned_on, :naive_datetime_query)
      resolve(&Resolvers.list_nodes/3)
    end

    @desc "Get all sensors"
    field :sensors, list_of(:sensor) do
      arg(:ontology, :string_query)
      resolve(&Resolvers.list_sensors/3)
    end

    @desc "Get all observations"
    field :observations, list_of(:observation) do
      arg(:timestamp, :naive_datetime_query)
      arg(:value, :float_query)
      arg(:within, :geojson_polygon)
      resolve(&Resolvers.list_observations/3)
    end
  end

  @doc """
  Gets called for every request. The `ctx` map looks like this:

  ```
    %{
      __absinthe_plug__: %{
        uploads: %{}
      },
      pubsub: AotWeb.Endpoint
    }
  ```

  We create a `Dataloader` struct and add it to the `ctx` map so that `Absinthe`
  knows what to use when generating database queries for `dataloader/1` invocations.

  https://github.com/absinthe-graphql/absinthe/blob/master/lib/absinthe/schema.ex#L53
  """
  def context(ctx) do
    loader =
      Dataloader.new()
      |> Dataloader.add_source(Repo, Repo.data())

    Map.put(ctx, :loader, loader)
  end

  def plugins() do
    [Absinthe.Middleware.Dataloader] ++ Absinthe.Plugin.defaults()
  end
end
