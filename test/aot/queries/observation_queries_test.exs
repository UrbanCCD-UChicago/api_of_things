defmodule Aot.Testing.ObservationQueriesTest do
  use Aot.Testing.BaseCase
  use Aot.Testing.DataCase

  alias Aot.ObservationActions

  describe "value" do
    @value 54.5

    test "eq" do
      obs = ObservationActions.list(value: {:eq, @value})
      assert length(obs) == 0
    end

    test "lt" do
      obs = ObservationActions.list(value: {:lt, @value})
      assert length(obs) == 40
    end

    test "le" do
      obs = ObservationActions.list(value: {:le, @value})
      assert length(obs) == 40
    end

    test "ge" do
      obs = ObservationActions.list(value: {:ge, @value})
      assert length(obs) == 32
    end

    test "gt" do
      obs = ObservationActions.list(value: {:gt, @value})
      assert length(obs) == 32
    end

    test "first" do
      [%{first: first_obs}] = ObservationActions.list(value: :first)
      assert is_float(first_obs)
    end

    test "last" do
      [%{last: last_obs}] = ObservationActions.list(value: :last)
      assert is_float(last_obs)
    end

    test "count" do
      ObservationActions.list(value: {:count, :node_id})
      |> Enum.each(fn %{group: _, count: count} -> assert count >= 0 end)
    end

    test "min" do
      ObservationActions.list(value: {:min, :node_id})
      |> Enum.each(fn %{group: _, min: min} -> assert is_float(min) end)
    end

    test "max" do
      ObservationActions.list(value: {:max, :node_id})
      |> Enum.each(fn %{group: _, max: max} -> assert is_float(max) end)
    end

    test "avg" do
      ObservationActions.list(value: {:avg, :node_id})
      |> Enum.each(fn %{group: _, avg: avg} -> assert is_float(avg) end)
    end

    test "sum" do
      ObservationActions.list(value: {:sum, :node_id})
      |> Enum.each(fn %{group: _, sum: sum} -> assert is_float(sum) end)
    end

    test "stddev" do
      ObservationActions.list(value: {:stddev, :node_id})
      |> Enum.each(fn %{group: _, stddev: stddev} -> assert is_float(stddev) end)
    end

    test "variance" do
      ObservationActions.list(value: {:variance, :node_id})
      |> Enum.each(fn %{group: _, variance: variance} -> assert is_float(variance) end)
    end

    test "percentile (.5 ~ median)" do
      ObservationActions.list(value: {:percentile, 0.5, :node_id})
      |> Enum.each(fn %{group: _, value: median} -> assert is_float(median) end)
    end
  end

  describe "as_histogram" do
    test "should return a map with keys 'group' and 'histogram'" do
      ObservationActions.list(as_histogram: {0, 100, 10, :node_id})
      |> Enum.each(fn obj ->
        assert is_map(obj)
        assert Map.has_key?(obj, :group)
        assert Map.has_key?(obj, :histogram)
      end)
    end

    test "histogram should be a list of numbers" do
      ObservationActions.list(as_histogram: {0, 100, 10, :node_id})
      |> Enum.each(fn hist ->
        assert is_list(hist[:histogram])
      end)
    end
  end

  describe "as_time_buckets" do
    test "count" do
      ObservationActions.list(as_time_buckets: {:count, "1 seconds"})
      |> Enum.each(fn %{bucket: _, count: count} -> assert count >= 0 end)
    end

    test "min" do
      ObservationActions.list(as_time_buckets: {:min, "1 seconds"})
      |> Enum.each(fn %{bucket: _, min: min} -> assert is_float(min) end)
    end

    test "max" do
      ObservationActions.list(as_time_buckets: {:max, "1 seconds"})
      |> Enum.each(fn %{bucket: _, max: max} -> assert is_float(max) end)
    end

    test "avg" do
      ObservationActions.list(as_time_buckets: {:avg, "1 seconds"})
      |> Enum.each(fn %{bucket: _, avg: avg} -> assert is_float(avg) end)
    end

    test "sum" do
      ObservationActions.list(as_time_buckets: {:sum, "1 seconds"})
      |> Enum.each(fn %{bucket: _, sum: sum} -> assert is_float(sum) end)
    end

    test "stddev" do
      ObservationActions.list(as_time_buckets: {:stddev, "1 seconds"})
      |> Enum.each(fn %{bucket: _, stddev: stddev} -> assert is_float(stddev) end)
    end

    test "variance" do
      ObservationActions.list(as_time_buckets: {:variance, "1 seconds"})
      |> Enum.each(fn %{bucket: _, variance: variance} -> assert is_float(variance) end)
    end

    test "percentile (.5 ~ median)" do
      ObservationActions.list(as_time_buckets: {:percentile, 0.5, "1 seconds"})
      |> Enum.each(fn %{bucket: _, value: value} -> assert is_float(value) end)
    end
  end
end
