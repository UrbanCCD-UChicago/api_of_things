alias Aot.{Repo, NetworkActions}
alias AotJobs.{DBManager, Importer}
import Ecto.Query

{:ok, chi} = NetworkActions.get("chicago")
