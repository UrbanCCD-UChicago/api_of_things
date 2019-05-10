defmodule Aot.Metrics do
  @moduledoc ""

  import Ecto.Query, warn: false
  import Aot.QueryUtils
  alias Aot.Metrics.MetricQueries
  alias Aot.Repo

  @doc ""
  def list_metrics(opts \\ []) do
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

    MetricQueries.list()
    |> filter_compose(opts[:for_node], MetricQueries, :for_node)
    |> filter_compose(opts[:for_sensor], MetricQueries, :for_sensor)
    |> filter_compose(opts[:for_project], MetricQueries, :for_project)
    |> filter_compose(opts[:located_within], MetricQueries, :located_within)
    |> filter_compose(opts[:located_dwithin], MetricQueries, :located_dwithin)
    |> filter_compose(opts[:timestamp], MetricQueries, :timestamp)
    |> filter_compose(opts[:value], MetricQueries, :value)
    |> filter_compose(opts[:order], MetricQueries, :order)
    |> filter_compose(opts[:paginate], MetricQueries, :paginate)
    |> filter_compose(opts[:histogram], MetricQueries, :histogram)
    |> filter_compose(opts[:time_bucket], MetricQueries, :time_bucket)
    |> Repo.all()
  end
end
