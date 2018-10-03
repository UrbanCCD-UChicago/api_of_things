defmodule Aot.Testing.QueryUtilsTest do
  use ExUnit.Case

  alias Aot.NetworkActions

  setup_all do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Aot.Repo)
    :ok = Ecto.Adapters.SQL.Sandbox.mode(Aot.Repo, {:shared, self()})

    1..9
    |> Enum.each(fn x ->
      {:ok, _} =

        NetworkActions.create(
          name: "Network #{x}",
          archive_url: "https://example.com/archive-#{x}",
          recent_url: "https://example.com/recent-#{x}",
          first_observation: NaiveDateTime.utc_now(),
          latest_observation: NaiveDateTime.utc_now()
        )
    end)
  end

  describe "order/2" do
    test "ascending" do
      networks = NetworkActions.list(order: {:asc, :first_observation})

      networks
      |> Enum.with_index()
      |> Enum.each(fn {net, idx} ->
        next = Enum.at(networks, idx + 1)
        case next do
          nil -> :ok
          next -> assert Timex.compare(net.first_observation, next.first_observation) == -1
        end
      end)
    end

    test "descending" do
      networks = NetworkActions.list(order: {:desc, :first_observation})

      networks
      |> Enum.with_index()
      |> Enum.each(fn {net, idx} ->
        next = Enum.at(networks, idx + 1)
        case next do
          nil -> :ok
          next -> assert Timex.compare(net.first_observation, next.first_observation) == 1
        end
      end)
    end
  end

  describe "paginate/2" do
    test "negative page causes an error" do
      assert_raise RuntimeError, fn ->
        NetworkActions.list(paginate: {-1, 100})
      end
    end

    test "negative size causes an error" do
      assert_raise RuntimeError, fn ->
        NetworkActions.list(paginate: {1, -100})
      end
    end

    test "float page causes an error" do
      assert_raise RuntimeError, fn ->
        NetworkActions.list(paginate: {1.1, 100})
      end
    end

    test "float size causes an error" do
      assert_raise RuntimeError, fn ->
        NetworkActions.list(paginate: {1, 100.1})
      end
    end

    test "string page causes an error" do
      assert_raise RuntimeError, fn ->
        NetworkActions.list(paginate: {"first", 100})
      end
    end

    test "string size causes an error" do
      assert_raise RuntimeError, fn ->
        NetworkActions.list(paginate: {1, "one-hundred"})
      end
    end

    test "not trying to be a smart ass gets you what you want" do
      networks = NetworkActions.list(paginate: {1, 4})
      assert length(networks) == 4

      networks = NetworkActions.list(paginate: {2, 4})
      assert length(networks) == 4

      networks = NetworkActions.list(paginate: {3, 4})
      assert length(networks) == 1
    end
  end
end
