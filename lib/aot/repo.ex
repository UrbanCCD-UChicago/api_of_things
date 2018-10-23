defmodule Aot.Repo do
  use Ecto.Repo,
    otp_app: :aot,
    adapter: Ecto.Adapters.Postgres

  def data() do
    Dataloader.Ecto.new(__MODULE__, query: &query/2)
  end

  def query(queryable, _params) do
    queryable
  end
end
