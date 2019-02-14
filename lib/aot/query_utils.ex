defmodule Aot.QueryUtils do

  import Ecto.Query
  alias Ecto.Queryable

  @doc ""
  @spec bool_compose(Queryable.t(), bool(), module(), atom()) :: Queryable.t()
  def bool_compose(query, false, _, _), do: query
  def bool_compose(query, true, module, fun), do: apply(module, fun, [query])

  @doc ""
  @spec filter_compose(Queryable.t(), :empty | list(any()) | any(), module(), atom()) :: Queryable.t()
  def filter_compose(query, :empty, _, _), do: query
  def filter_compose(query, args, module, fun) when is_list(args), do: apply(module, fun, [query] ++ args)
  def filter_compose(query, args, module, fun) when not is_list(args), do: apply(module, fun, [query] ++ [args])

  @doc ""
  @spec order(Queryable.t(), :asc | :desc, atom()) :: Queryable.t()
  def order(query, direction, field_name) do
    case Enum.empty?(query.order_bys) do
      true -> do_order(query, direction, field_name)
      false -> query
    end
  end

  defp do_order(query, direction, field_name) when not is_atom(field_name), do: do_order(query, direction, String.to_atom(field_name))
  defp do_order(query, "asc", field_name), do: order_by(query, [q], asc: ^field_name)
  defp do_order(query, "desc", field_name), do: order_by(query, [q], desc: ^field_name)

  @doc ""
  @spec paginate(Queryable.t(), pos_integer(), pos_integer()) :: Queryable.t()
  def paginate(query, page_num, page_size) do
    cond do
      !is_integer(page_num) or page_num < 1 -> raise "page must be a positive integer"
      !is_integer(page_size) or page_size < 1 -> raise "size must be a positive integer"
      true -> :ok
    end

    starting_at = (page_num - 1) * page_size

    query
    |> offset(^starting_at)
    |> limit(^page_size)
  end
end
