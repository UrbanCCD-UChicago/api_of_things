defmodule Aot.Repo do
  use Ecto.Repo,
    otp_app: :aot,
    adapter: Ecto.Adapters.Postgres
end
