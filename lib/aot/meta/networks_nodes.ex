defmodule Aot.Meta.NetworksNodes do
  use Ecto.Schema
  import Ecto.Changeset

  schema "networks_nodes" do
    belongs_to :network, Aot.Meta.Network
    belongs_to :node, Aot.Meta.Node
  end

  @doc false
  def changeset(network_node, attrs) do
    network_node
    |> cast(attrs, [:network_id, :node_id])
    |> validate_required([:network_id, :node_id])
    |> foreign_key_constraint(:network_id)
    |> foreign_key_constraint(:node_id)
  end
end
