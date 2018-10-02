defmodule Aot.NetworkNode do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "networks_nodes" do
    belongs_to :network, Aot.Network
    belongs_to :node, Aot.Node, type: :string
  end

  @doc false
  def changeset(network_node, attrs) do
    network_node
    |> cast(attrs, [:network_id, :node_id])
    |> validate_required([:network_id, :node_id])
    |> foreign_key_constraint(:network_id)
    |> foreign_key_constraint(:node_id)
    |> unique_constraint(:network_id, name: :networks_nodes_uniq)
  end
end
