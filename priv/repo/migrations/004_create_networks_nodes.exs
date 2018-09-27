defmodule Aot.MetaRepo.Migrations.CreateNetworksNodes do
  use Ecto.Migration

  def change do
    create table(:networks_nodes) do
      add :network_id, references(:networks, on_delete: :restrict)
      add :node_id, references(:nodes, type: :text, on_delete: :restrict)
    end

    create unique_index(:networks_nodes, [:network_id, :node_id])
    create index(:networks_nodes, :network_id)
    create index(:networks_nodes, :node_id)
  end
end
