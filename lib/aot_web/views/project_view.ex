defmodule AotWeb.ProjectView do
  use AotWeb, :view
  import AotWeb.ViewUtils
  alias AotWeb.ProjectView

  def render("index.json", %{projects: projects, format: format, meta: meta}) do
    %{data: render_many(projects, ProjectView, "project.#{format}"), meta: meta}
  end

  def render("show.json", %{project: project, format: format}) do
    %{data: render_one(project, ProjectView, "project.#{format}")}
  end

  def render("project.json", %{project: project}) do
    %{
      name: project.name,
      slug: project.slug,
      archive_url: project.archive_url,
      hull: encode_geom(project.hull)
    }
  end

  def render("project.geojson", %{project: project}) do
    %{
      type: "Feature",
      geometry: encode_geom(project.hull)[:geometry],
      properties: %{
        name: project.name,
        slug: project.slug,
        archive_url: project.archive_url
      }
    }
  end
end
