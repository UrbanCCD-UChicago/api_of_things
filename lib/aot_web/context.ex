defmodule AotWeb.Context do
  alias Aot.Repo

  def dataloader() do
    Dataloader.new
    |> Dataloader.add_source(Repo, Repo.data())
  end
end
