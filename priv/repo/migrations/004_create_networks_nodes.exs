defmodule Aot.Repo.Migrations.CreateNetworksNodes do
  use Ecto.Migration

  def change do
    create table(:networks_nodes) do
      add :network_id, references(:networks, on_delete: :delete_all)
      add :node_id, references(:nodes, type: :text, on_delete: :delete_all)
    end

    create unique_index(:networks_nodes, [:network_id, :node_id], name: :networks_nodes_uniq)
    create index(:networks_nodes, :network_id)
    create index(:networks_nodes, :node_id)
  end
end
