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
  @spec parse_relation(map(), atom(), atom()) :: map()
  def parse_relation(params, struct_name, field_name) do
    fk = String.to_atom("#{struct_name}_#{field_name}")

    value =
      case Map.get(params, struct_name) do
        nil ->
          Map.get(params, fk)

        strukt ->
          Map.get(strukt, field_name)
      end

    Map.put(params, fk, value)
  end

  @doc """
  Parses the timestamps found in the AoT archive files... because apparently
  dumping values to an acutally readable ISO 8601 format is too much to ask for.
  """
  @spec parse_timestamp(String.t()) :: NaiveDateTime.t() | no_return()
  def parse_timestamp(nil), do: nil
  def parse_timestamp(value), do: Timex.parse!(value, "%Y/%m/%d %H:%M:%S", :strftime)
end
