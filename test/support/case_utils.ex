defmodule Aot.CaseUtils do
  alias Aot.{Projects, Sensors, Nodes}

  def build_context(tags) do
    context = []

    add2ctx = tags[:add2ctx] || []
    add2ctx =
      case is_list(add2ctx) do
        true -> add2ctx
        false -> [add2ctx]
      end

    context =
      if :projects in add2ctx do
        Projects.list_projects()
        |> Enum.map(& {String.to_atom(&1.slug), &1})
        |> Keyword.merge(context)
      else
        context
      end

    context =
      if :sensors in add2ctx do
        Sensors.list_sensors()
        |> Enum.map(& {String.to_atom(String.replace(&1.path, ".", "_")), &1})
        |> Keyword.merge(context)
      else
        context
      end

    if :nodes in add2ctx do
      Nodes.list_nodes()
      |> Enum.map(& {:"n#{&1.vsn}", &1})
      |> Keyword.merge(context)
    else
      context
    end
  end
end
