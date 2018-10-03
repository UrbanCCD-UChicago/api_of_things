defmodule Aot.QueryUtils do
  @moduledoc """
  A dumping ground for common functions used by the query modules.
  """

  import Ecto.Query

  @doc """
  Genreically applies ordering. This should be delegated to from the query modules.
  """
  @spec order(Ecto.Queryable.t(), {:asc | :desc, atom()}) :: Ecto.Queryable.t()
  def order(query, {:asc, fname}), do: order_by(query, [q], asc: ^fname)
  def order(query, {:desc, fname}), do: order_by(query, [q], desc: ^fname)

  @doc """
  Generically applies pagination. This should be delegated to from the query modules.
  """
  @spec paginate(Ecto.Queryable.t(), {non_neg_integer(), non_neg_integer()}) :: Ecto.Queryable.t() | no_return()
  def paginate(query, {page, size}) do
    cond do
      !is_integer(page) or page < 1 -> raise "page must be a non-negative integer"
      !is_integer(size) or size < 1 -> raise "size must be a non-negative integer"
      true -> :ok
    end

    starting_at = (page - 1) * size

    query
    |> offset(^starting_at)
    |> limit(^size)
  end

  @doc """
  Applies an arithmetic function to a given field.
  """
  @spec field_op(Ecto.Queryable.t(), atom(), atom(), any()) :: Ecto.Queryable.t()
  def field_op(query, fname, :eq, value), do: where(query, [q], field(q, ^fname) == ^value)
  def field_op(query, fname, :lt, value), do: where(query, [q], field(q, ^fname) < ^value)
  def field_op(query, fname, :le, value), do: where(query, [q], field(q, ^fname) <= ^value)
  def field_op(query, fname, :gt, value), do: where(query, [q], field(q, ^fname) > ^value)
  def field_op(query, fname, :ge, value), do: where(query, [q], field(q, ^fname) >= ^value)
  def field_op(query, fname, :in, value), do: where(query, [q], field(q, ^fname) in ^value)
  def field_op(query, fname, :between, {lo, hi}),
    do: where(query, [q], fragment("? between ? and ?", field(q, ^fname), ^lo, ^hi))

  @doc """
  Applies an arithmetic function to a given field and explicitly cast the type of the argument.
  """
  @spec typed_field_op(Ecto.Queryable.t(), atom(), atom(), any(), atom()) :: Ecto.Queryable.t()
  def typed_field_op(query, fname, :eq, value, vtype), do: where(query, [q], field(q, ^fname) == type(^value, ^vtype))
  def typed_field_op(query, fname, :lt, value, vtype), do: where(query, [q], field(q, ^fname) < type(^value, ^vtype))
  def typed_field_op(query, fname, :le, value, vtype), do: where(query, [q], field(q, ^fname) <= type(^value, ^vtype))
  def typed_field_op(query, fname, :gt, value, vtype), do: where(query, [q], field(q, ^fname) > type(^value, ^vtype))
  def typed_field_op(query, fname, :ge, value, vtype), do: where(query, [q], field(q, ^fname) >= type(^value, ^vtype))
  def typed_field_op(query, fname, :in, value, vtype), do: where(query, [q], field(q, ^fname) in type(^value, ^vtype))
  def typed_field_op(query, fname, :between, {lo, hi}, vtype),
    do: where(query, [q], fragment("? between ? and ?", field(q, ^fname), type(^lo, ^vtype), type(^hi, ^vtype)))

  @doc """
  Applies the given `module.func` to the query if the flag is true, otherwise it
  simply returns the query unmodified.
  """
  @spec boolean_compose(Ecto.Queryable.t(), boolean(), module(), fun()) :: Ecto.Queryable.t()
  def boolean_compose(query, false, _module, _func), do: query
  def boolean_compose(query, true, module, func), do: apply(module, func, [query])

  @doc """
  Applies the given `module.func` to the query with the given `value` as the parameter
  to the function if the value is not :empty, otherwise it returns the query unmodified.
  """
  @spec filter_compose(Ecto.Queryable.t(), :empty | any(), module(), fun()) :: Ecto.Queryable.t()
  def filter_compose(query, :empty, _module, _func), do: query
  def filter_compose(query, value, module, func), do: apply(module, func, [query, value])

  @doc """
  Generically applies `boolean_compose` and `filter_compose` to a query based on the
  mapping given in the opts parameter. The keys of the opts must match the function
  names in the module that will be applied.
  """
  @spec apply_opts(keyword(), Ecto.Queryable.t(), module()) :: Ecto.Queryable.t()
  def apply_opts(opts, query, module) do
    Enum.reduce(opts, query, fn {key, value}, query ->
      case is_boolean(value) do
        true -> boolean_compose(query, value, module, key)
        false -> filter_compose(query, value, module, key)
      end
    end)
  end
end
