alias Aot.ProjectActions
alias AotJobs.Importer

{:ok, project} = 
  ProjectActions.create name: "Chicago",
    archive_url: "https://www.mcs.anl.gov/research/projects/waggle/downloads/datasets/AoT_Chicago.complete.latest.tar",
    recent_url: "https://www.mcs.anl.gov/research/projects/waggle/downloads/datasets/AoT_Chicago.complete.recent.tar"

Importer.import(project)
