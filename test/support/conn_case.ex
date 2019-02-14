defmodule AotWeb.ConnCase do
  use ExUnit.CaseTemplate
  import Aot.CaseUtils

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest
      alias AotWeb.Router.Helpers, as: Routes
      @endpoint AotWeb.Endpoint
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Aot.Repo)

    unless tags[:async] do
      :ok = Ecto.Adapters.SQL.Sandbox.mode(Aot.Repo, {:shared, self()})
    end

    context = Keyword.merge(build_context(tags), [conn: Phoenix.ConnTest.build_conn()])

    {:ok, context}
  end
end
