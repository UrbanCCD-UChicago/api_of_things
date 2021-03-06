defmodule AotWeb.ViewUtils do
  import Phoenix.View, only: [render_many: 3, render_one: 3]

  def encode_geom(nil), do: nil
  def encode_geom(geom), do: %{type: "Feature", geometry: Geo.JSON.encode!(geom)}

  def nest_related(json, key, rel_attr, rel_view, rel_template),
    do: nest_related(json, key, rel_attr, rel_view, rel_template, :many)

  def nest_related(json, key, rel_attr, rel_view, rel_template, :one) do
    case Ecto.assoc_loaded?(rel_attr) do
      false -> json
      true -> Map.put(json, key, render_one(rel_attr, rel_view, rel_template))
    end
  end

  def nest_related(json, key, rel_attr, rel_view, rel_template, :many) do
    case Ecto.assoc_loaded?(rel_attr) do
      false -> json
      true -> Map.put(json, key, render_many(rel_attr, rel_view, rel_template))
    end
  end
end
