defmodule Aot.Testing.RawObservationQueriesTest do
  use Aot.Testing.BaseCase
  use Aot.Testing.DataCase

  alias Aot.RawObservationActions

  describe "raw" do
    @value 54.5

    test "eq" do
      obs = RawObservationActions.list(raw: {:eq, @value})
      assert length(obs) == 0
    end

    test "lt" do
      obs = RawObservationActions.list(raw: {:lt, @value})
      assert length(obs) == 361
    end

    test "le" do
      obs = RawObservationActions.list(raw: {:le, @value})
      assert length(obs) == 361
    end

    test "ge" do
      obs = RawObservationActions.list(raw: {:ge, @value})
      assert length(obs) == 2906
    end

    test "gt" do
      obs = RawObservationActions.list(raw: {:gt, @value})
      assert length(obs) == 2906
    end
  end

  describe "hrf" do
    @value 54.5

    test "eq" do
      obs = RawObservationActions.list(hrf: {:eq, @value})
      assert length(obs) == 0
    end

    test "lt" do
      obs = RawObservationActions.list(hrf: {:lt, @value})
      assert length(obs) == 2023
    end

    test "le" do
      obs = RawObservationActions.list(hrf: {:le, @value})
      assert length(obs) == 2023
    end

    test "ge" do
      obs = RawObservationActions.list(hrf: {:ge, @value})
      assert length(obs) == 552
    end

    test "gt" do
      obs = RawObservationActions.list(hrf: {:gt, @value})
      assert length(obs) == 552
    end
  end

  describe "compute_aggs" do
    test "first" do
      [%{raw_first: raw, hrf_first: hrf}] = RawObservationActions.list(compute_aggs: :first)
      assert is_float(raw)
      assert is_float(hrf)
    end

    test "last" do
      [%{raw_last: raw, hrf_last: hrf}] = RawObservationActions.list(compute_aggs: :last)
      assert is_float(raw)
      assert is_float(hrf)
    end

    test "count" do
      RawObservationActions.list(compute_aggs: {:count, :node_id})
      |> Enum.each(fn %{group: _, raw_count: raw, hrf_count: hrf} ->
        assert raw >= 0
        assert hrf >= 0
      end)
    end

    test "min" do
      RawObservationActions.list(compute_aggs: {:min, :node_id})
      |> Enum.each(fn %{group: _, raw_min: raw, hrf_min: hrf} ->
        assert is_float(raw)
        assert is_float(hrf)
      end)
    end

    test "max" do
      RawObservationActions.list(compute_aggs: {:max, :node_id})
      |> Enum.each(fn %{group: _, raw_max: raw, hrf_max: hrf} ->
        assert is_float(raw)
        assert is_float(hrf)
      end)
    end

    test "avg" do
      RawObservationActions.list(compute_aggs: {:avg, :node_id})
      |> Enum.each(fn %{group: _, raw_avg: raw, hrf_avg: hrf} ->
        assert is_float(raw)
        assert is_float(hrf)
      end)
    end

    test "sum" do
      RawObservationActions.list(compute_aggs: {:sum, :node_id})
      |> Enum.each(fn %{group: _, raw_sum: raw, hrf_sum: hrf} ->
        assert is_float(raw)
        assert is_float(hrf)
      end)
    end

    test "stddev" do
      RawObservationActions.list(compute_aggs: {:stddev, :node_id})
      |> Enum.each(fn %{group: _, raw_stddev: raw, hrf_stddev: hrf} ->
        assert is_float(raw)
        assert is_float(hrf)
      end)
    end

    test "variance" do
      RawObservationActions.list(compute_aggs: {:variance, :node_id})
      |> Enum.each(fn %{group: _, raw_variance: raw, hrf_variance: hrf} ->
        assert is_float(raw)
        assert is_float(hrf)
      end)
    end

    test "percentile (.5 ~ median)" do
      RawObservationActions.list(compute_aggs: {:percentile, 0.5, :node_id})
      |> Enum.each(fn %{group: _, raw_value: raw, hrf_value: hrf} ->
        assert is_float(raw)
        assert is_float(hrf)
      end)
    end
  end

  describe "as_histograms" do
    test "should return a map with keys 'group' and 'X_histogram'" do
      RawObservationActions.list(as_histograms: {0, 100, 0, 100, 10, :node_id})
      |> Enum.each(fn obj ->
        assert is_map(obj)
        assert Map.has_key?(obj, :group)
        assert Map.has_key?(obj, :raw_histogram)
        assert Map.has_key?(obj, :hrf_histogram)
      end)
    end

    test "histograms should be a list of numbers" do
      RawObservationActions.list(as_histograms: {0, 100, 0, 100, 10, :node_id})
      |> Enum.each(fn hist ->
        assert is_list(hist[:raw_histogram])
        assert is_list(hist[:hrf_histogram])
      end)
    end
  end

  describe "as_time_buckets" do
    test "count" do
      RawObservationActions.list(as_time_buckets: {:count, "1 seconds"})
      |> Enum.each(fn %{bucket: _, raw_count: raw, hrf_count: hrf} ->
        assert raw >= 0
        assert hrf >= 0
      end)
    end

    test "min" do
      RawObservationActions.list(as_time_buckets: {:min, "1 seconds"})
      |> Enum.each(fn %{bucket: _, raw_min: raw, hrf_min: hrf} ->
        assert is_float(raw)
        assert is_float(hrf)
      end)
    end

    test "max" do
      RawObservationActions.list(as_time_buckets: {:max, "1 seconds"})
      |> Enum.each(fn %{bucket: _, raw_max: raw, hrf_max: hrf} ->
        assert is_float(raw)
        assert is_float(hrf)
      end)
    end

    test "avg" do
      RawObservationActions.list(as_time_buckets: {:avg, "1 seconds"})
      |> Enum.each(fn %{bucket: _, raw_avg: raw, hrf_avg: hrf} ->
        assert is_float(raw)
        assert is_float(hrf)
      end)
    end

    test "sum" do
      RawObservationActions.list(as_time_buckets: {:sum, "1 seconds"})
      |> Enum.each(fn %{bucket: _, raw_sum: raw, hrf_sum: hrf} ->
        assert is_float(raw)
        assert is_float(hrf)
      end)
    end

    test "stddev" do
      RawObservationActions.list(as_time_buckets: {:stddev, "1 seconds"})
      |> Enum.each(fn %{bucket: _, raw_stddev: raw, hrf_stddev: hrf} ->
        assert is_float(raw)
        assert is_float(hrf)
      end)
    end

    test "variance" do
      RawObservationActions.list(as_time_buckets: {:variance, "1 seconds"})
      |> Enum.each(fn %{bucket: _, raw_variance: raw, hrf_variance: hrf} ->
        assert is_float(raw)
        assert is_float(hrf)
      end)
    end

    test "percentile (.5 ~ median)" do
      RawObservationActions.list(as_time_buckets: {:percentile, 0.5, "1 seconds"})
      |> Enum.each(fn %{bucket: _, raw_value: raw, hrf_value: hrf} ->
        assert is_float(raw)
        assert is_float(hrf)
      end)
    end
  end
end
