defmodule Aot.Observations do
  @moduledoc ""

  import Ecto.Query, warn: false
  import Aot.QueryUtils
  alias Aot.Observations.ObservationQueries
  alias Aot.Repo

  @doc ""
  def list_observations(opts \\ []) do
    opts = Keyword.merge([
      for_node: :empty,
      for_sensor: :empty,
      for_project: :empty,
      located_within: :empty,
      located_dwithin: :empty,
      timestamp: :empty,
      value: :empty,
      histogram: :empty,
      time_bucket: :empty,
      order: :empty,
      paginate: :empty
    ], opts)

    ObservationQueries.list()
    |> filter_compose(opts[:for_node], ObservationQueries, :for_node)
    |> filter_compose(opts[:for_sensor], ObservationQueries, :for_sensor)
    |> filter_compose(opts[:for_project], ObservationQueries, :for_project)
    |> filter_compose(opts[:located_within], ObservationQueries, :located_within)
    |> filter_compose(opts[:located_dwithin], ObservationQueries, :located_dwithin)
    |> filter_compose(opts[:timestamp], ObservationQueries, :timestamp)
    |> filter_compose(opts[:value], ObservationQueries, :value)
    |> filter_compose(opts[:order], ObservationQueries, :order)
    |> filter_compose(opts[:paginate], ObservationQueries, :paginate)
    |> filter_compose(opts[:histogram], ObservationQueries, :histogram)
    |> filter_compose(opts[:time_bucket], ObservationQueries, :time_bucket)
    |> Repo.all()
  end
end
