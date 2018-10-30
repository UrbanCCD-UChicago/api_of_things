defmodule AotWeb.Schema do
  use Absinthe.Schema
  import_types(AotWeb.Schema.Types)
  import_types(Absinthe.Type.Custom)
  alias Aot.Repo
  alias AotWeb.Resolvers

  query do
    @desc "Get all projects"
    field :projects, list_of(:project) do
      arg(:name, :string_query)
      arg(:archive_url, :string_query)
      arg(:recent_url, :string_query)
      arg(:first_observation, :naive_datetime_query)
      arg(:latest_observation, :naive_datetime_query)
      arg(:bbox, :string_query)
      arg(:hull, :string_query)
      resolve(&Resolvers.list_projects/3)
    end

    @desc "Get all nodes"
    field :nodes, list_of(:node) do
      arg(:id, :string_query)
      arg(:location, :string_query)
      arg(:latitude, :float_query)
      arg(:longitude, :float_query)
      arg(:description, :string_query)
      arg(:address, :string_query)
      arg(:commissioned_on, :naive_datetime_query)
      arg(:decommissioned_on, :naive_datetime_query)
      resolve(&Resolvers.list_nodes/3)
    end

    @desc "Get all sensors"
    field :sensors, list_of(:sensor) do
      arg(:ontology, :string_query)
      arg(:subsystem, :string_query)
      arg(:sensor, :string_query)
      arg(:parameter, :string_query)
      arg(:uom, :string_query)
      arg(:min, :float_query)
      arg(:max, :float_query)
      arg(:data_sheet, :string_query)
      resolve(&Resolvers.list_sensors/3)
    end

    @desc "Get all observations"
    field :observations, list_of(:observation) do
      arg(:timestamp, :naive_datetime_query)
      arg(:value, :float_query)
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
