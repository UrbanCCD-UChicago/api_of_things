defmodule Aot.Testing.BaseCase do
  use ExUnit.CaseTemplate

  setup_all tags do
    # sandbox the repo
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Aot.Repo)
    unless tags[:async] do
      :ok = Ecto.Adapters.SQL.Sandbox.mode(Aot.Repo, {:shared, self()})
    end
    :ok
  end
end
