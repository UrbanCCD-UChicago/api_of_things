defmodule Aot.NetworkNode do
  use Ecto.Schema
  import Ecto.Changeset

  schema "networks_nodes" do
    belongs_to :network, Aot.Network,
      foreign_key: :network_slug,
      references: :slug,
      type: :string

    belongs_to :node, Aot.Node,
      foreign_key: :node_id,
      references: :id,
      type: :string
  end

  @doc false
  def changeset(network_node, attrs) do
    network_node
    |> cast(attrs, [:network_slug, :node_id])
    |> validate_required([:network_slug, :node_id])
    |> foreign_key_constraint(:network_slug)
    |> foreign_key_constraint(:node_id)
    |> unique_constraint(:network_slug, name: :networks_nodes_uniq)
  end
end
