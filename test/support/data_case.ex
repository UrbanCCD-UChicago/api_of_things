defmodule Aot.Testing.DataCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias Aot.Repo
      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import Aot.Testing.DataCase
    end
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
