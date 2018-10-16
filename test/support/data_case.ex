defmodule Aot.Testing.DataCase do
  use ExUnit.CaseTemplate

  import Mock

  alias Aot.{
    NetworkActions,
    NodeActions,
    SensorActions
  }

  alias AotJobs.Importer

  using do
    quote do
      alias Aot.Repo
      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import Aot.Testing.DataCase
    end
  end

  defp mock_chicago(_) do
    content =
      "test/fixtures/chicago.tar"
      |> File.read!()

    %HTTPoison.Response{body: content}
  end

  defp mock_detroit(_) do
    content =
      "test/fixtures/detroit.tar"
      |> File.read!()

    %HTTPoison.Response{body: content}
  end

  defp mock_portland(_) do
    content =
      "test/fixtures/portland.tar"
      |> File.read!()

    %HTTPoison.Response{body: content}
  end

  setup_all do
    # setup chicago network
    {:ok, chicago} =
      NetworkActions.create name: "Chicago",
        archive_url: "https://example.com/archives/chicago",
        recent_url: "https://example.com/recents/chicago"

    with_mock HTTPoison, get!: &mock_chicago/1 do
      Importer.import(chicago)
    end

    bbox = NetworkActions.compute_bbox(chicago)
    hull = NetworkActions.compute_hull(chicago)
    {:ok, _} = NetworkActions.update(chicago, bbox: bbox, hull: hull)

    # setup detroit network
    {:ok, detroit} =
      NetworkActions.create name: "Detroit",
        archive_url: "https://example.com/archives/detroit",
        recent_url: "https://example.com/recents/detroit"

    with_mock HTTPoison, get!: &mock_detroit/1 do
      Importer.import(detroit)
    end

    bbox = NetworkActions.compute_bbox(detroit)
    hull = NetworkActions.compute_hull(detroit)
    {:ok, _} = NetworkActions.update(detroit, bbox: bbox, hull: hull)

    # setup portland network
    {:ok, portland} =
      NetworkActions.create name: "Portland",
        archive_url: "https://example.com/archives/portland",
        recent_url: "https://example.com/recents/portland"

    with_mock HTTPoison, get!: &mock_portland/1 do
      Importer.import(portland)
    end

    bbox = NetworkActions.compute_bbox(portland)
    hull = NetworkActions.compute_hull(portland)
    {:ok, _} = NetworkActions.update(portland, bbox: bbox, hull: hull)

    :ok
  end

  setup tags do
    context = []
    add2ctx = tags[:add2ctx] || []
    add2ctx =
      case is_list(add2ctx) do
        true -> add2ctx
        false -> [add2ctx]
      end

    # add networks to context?
    context =
      case :networks in add2ctx do
        false ->
          context

        true ->
          NetworkActions.list()
          |> Enum.map(& {String.to_atom(String.replace(&1.slug, "-", "_")), &1})
          |> Keyword.merge(context)
      end

    # add nodes to context?
    context =
      case :nodes in add2ctx do
        false ->
          context

        true ->
          NodeActions.list()
          |> Enum.map(& {:"n#{&1.vsn}", &1})
          |> Keyword.merge(context)
      end

    # add sensors to context?
    context =
      case :sensors in add2ctx do
        false ->
          context

        true ->
          SensorActions.list(order: {:asc, :path})
          |> Enum.map(& {:"#{&1.sensor}_#{&1.parameter}", &1})
          |> Keyword.merge(context)
      end

    # return the context
    {:ok, context}
  end

  @doc """
  A helper that transform changeset errors to a map of messages.

      assert {:error, changeset} = Accounts.create_user(%{password: "short"})
      assert "password is too short" in errors_on(changeset).password
      assert %{password: ["password is too short"]} = errors_on(changeset)

  """
  def errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Enum.reduce(opts, message, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
