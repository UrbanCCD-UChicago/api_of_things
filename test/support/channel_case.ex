defmodule AotWeb.ChannelCase do
  use ExUnit.CaseTemplate
  import Aot.CaseUtils

  using do
    quote do
      # Import conveniences for testing with channels
      use Phoenix.ChannelTest

      # The default endpoint for testing
      @endpoint AotWeb.Endpoint
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Aot.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Aot.Repo, {:shared, self()})
    end

    {:ok, build_context(tags)}
  end
end
