defmodule Aot.Sensors do
  @moduledoc ""

  import Ecto.Query, warn: false
  import Aot.QueryUtils
  alias Aot.Repo
  alias Aot.Sensors.{Sensor, SensorQueries}

  @doc ""
  def list_sensors(opts \\ []) do
    opts = Keyword.merge([
      order: :empty,
      paginate: :empty
    ], opts)

    from(s in Sensor)
    |> filter_compose(opts[:order], SensorQueries, :order)
    |> filter_compose(opts[:paginate], SensorQueries, :paginate)
    |> Repo.all()
  end

  @doc ""
  def get_sensor(path) do
    case Repo.get_by(Sensor, path: path) do
      nil -> {:error, :not_found}
      sensor -> {:ok, sensor}
    end
  end
end
