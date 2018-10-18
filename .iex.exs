alias Aot.{Repo, ProjectActions}
alias AotJobs.{DBManager, Importer}
import Ecto.Query

{:ok, chi} = ProjectActions.get("chicago")
