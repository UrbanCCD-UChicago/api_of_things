defmodule AotWeb.Schema do
  use Absinthe.Schema
  import_types AotWeb.Schema.Types
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
  end
end
