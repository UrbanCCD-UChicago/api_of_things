defmodule AotWeb.ViewUtils do

  import Phoenix.View, only: [ render_many: 3 ]

  def encode_geom(nil), do: nil
  def encode_geom(geom), do: %{type: "Feature", geometry: Geo.JSON.encode!(geom)}

  def nest_related(rel_attr, rel_view, rel_template) do
    case Ecto.assoc_loaded?(rel_attr) do
      false -> []
      true -> render_many(rel_attr, rel_view, rel_template)
    end
  end
end
