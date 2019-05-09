# defmodule Seeds do
#   alias AotJobs.Importer

#   def import(project) do
#     tarball = "test/fixtures/#{project.slug}.tar"

#     :ok = Importer.ensure_clean_paths!(tarball)
#     data_dir = Importer.decompress!(project, tarball)
#     :ok = Importer.process_nodes_csv!(project, data_dir)
#     :ok = Importer.process_sensors_csv!(project, data_dir)
#     :ok = Importer.process_data_csv!(project, data_dir)
#     :ok = Importer.refresh_latest_observations!()
#     :ok = Importer.refresh_node_sensors!()

#     :ok
#   after
#     _ = System.cmd("rm", ["-r", "/tmp/aot-tarballs"])
#     :ok
#   end
# end

alias Aot.Projects

{:ok, _} = Projects.create_project(%{name: "Chicago",
  archive_url: "http://www.mcs.anl.gov/research/projects/waggle/downloads/datasets/AoT_Chicago.complete.latest.tar",
  recent_url: "http://www.mcs.anl.gov/research/projects/waggle/downloads/datasets/AoT_Chicago.complete.recent.tar"})

{:ok, _} = Projects.create_project(%{name: "Detroit",
  archive_url: "http://www.mcs.anl.gov/research/projects/waggle/downloads/datasets/AoT_Detroit.complete.latest.tar",
  recent_url: "http://www.mcs.anl.gov/research/projects/waggle/downloads/datasets/AoT_Detroit.complete.recent.tar"})

{:ok, _} = Projects.create_project(%{name: "Portland",
  archive_url: "http://www.mcs.anl.gov/research/projects/waggle/downloads/datasets/AoT_Portland.complete.latest.tar",
  recent_url: "http://www.mcs.anl.gov/research/projects/waggle/downloads/datasets/AoT_Portland.complete.recent.tar"})

{:ok, _} = Projects.create_project(%{name: "Seattle",
  archive_url: "http://www.mcs.anl.gov/research/projects/waggle/downloads/datasets/AoT_Seattle.complete.latest.tar",
  recent_url: "http://www.mcs.anl.gov/research/projects/waggle/downloads/datasets/AoT_Seattle.complete.recent.tar"})

{:ok, _} = Projects.create_project(%{name: "NIU",
  archive_url: "http://www.mcs.anl.gov/research/projects/waggle/downloads/datasets/AoT_NIU.complete.latest.tar",
  recent_url: "http://www.mcs.anl.gov/research/projects/waggle/downloads/datasets/AoT_NIU.complete.recent.tar"})

{:ok, _} = Projects.create_project(%{name: "Syracuse",
  archive_url: "http://www.mcs.anl.gov/research/projects/waggle/downloads/datasets/AoT_Syracuse.complete.latest.tar",
  recent_url: "http://www.mcs.anl.gov/research/projects/waggle/downloads/datasets/AoT_Syracuse.complete.recent.tar"})

{:ok, _} = Projects.create_project(%{name: "UNC",
  archive_url: "http://www.mcs.anl.gov/research/projects/waggle/downloads/datasets/AoT_UNC.complete.latest.tar",
  recent_url: "http://www.mcs.anl.gov/research/projects/waggle/downloads/datasets/AoT_UNC.complete.recent.tar"})

{:ok, _} = Projects.create_project(%{name: "UW",
  archive_url: "http://www.mcs.anl.gov/research/projects/waggle/downloads/datasets/AoT_UW.complete.latest.tar",
  recent_url: "http://www.mcs.anl.gov/research/projects/waggle/downloads/datasets/AoT_UW.complete.recent.tar"})

{:ok, _} = Projects.create_project(%{name: "Stanford",
  archive_url: "http://www.mcs.anl.gov/research/projects/waggle/downloads/datasets/AoT_Stanford.complete.latest.tar",
  recent_url: "http://www.mcs.anl.gov/research/projects/waggle/downloads/datasets/AoT_Stanford.complete.recent.tar"})

{:ok, _} = Projects.create_project(%{name: "Denver",
  archive_url: "http://www.mcs.anl.gov/research/projects/waggle/downloads/datasets/AoT_Denver.complete.latest.tar",
  recent_url: "http://www.mcs.anl.gov/research/projects/waggle/downloads/datasets/AoT_Denver.complete.recent.tar"})

{:ok, _} = Projects.create_project(%{name: "GA Tech",
  archive_url: "http://www.mcs.anl.gov/research/projects/waggle/downloads/datasets/AoT_GA_Tech.complete.latest.tar",
  recent_url: "http://www.mcs.anl.gov/research/projects/waggle/downloads/datasets/AoT_GA_Tech.complete.recent.tar"})

{:ok, _} = Projects.create_project(%{name: "Vanderbilt",
  archive_url: "http://www.mcs.anl.gov/research/projects/waggle/downloads/datasets/AoT_Vanderbilt.complete.latest.tar",
  recent_url: "http://www.mcs.anl.gov/research/projects/waggle/downloads/datasets/AoT_Vanderbilt.complete.recent.tar"})

# Seeds.import(chicago)
# Seeds.import(detroit)
# Seeds.import(portland)

AotJobs.Importer.import_projects()
