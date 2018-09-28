defmodule Aot.ActionUtils do
  @moduledoc """
  A dumping ground for common functions used in the action modules.
  """

  @doc """
  Converts a map or keyword list into a map with atom keys.
  """
  @spec atomize(any()) :: map()
  def atomize(params) do
    params
    |> Enum.map(fn {key, value} ->
      case is_atom(key) do
        true -> {key, value}
        false -> {String.to_atom("#{key}"), value}
      end
    end)
    |> Enum.into(%{})
  end

  @doc """
  Parses a map to check if a related struct or id exists and updates
  the map with the id/value pair.
  """
  @spec parse_rel(map(), atom()) :: map()
  def parse_rel(params, key) do
    id_key = String.to_atom("#{Atom.to_string(key)}_id")

    id_value =
      case Map.has_key?(params, key) do
        true ->
          strukt = params[key]
          strukt.id

        false ->
          Map.get(params, id_key, nil)
      end

    Map.put(params, id_key, id_value)
  end
end
