defmodule Ekg.Packet do
  use Ekg.Web, :model

  schema "packets" do
    field :node_id, :integer
    field :child_node_id, :integer
    field :msg_type, :integer
    field :ack, :integer
    field :subtype, :integer
    field :payload, :string

    timestamps
  end

  @required_fields ~w(node_id child_node_id msg_type ack subtype payload)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
