defmodule Ekg.PacketTest do
  use Ekg.ModelCase

  alias Ekg.Packet

  @valid_attrs %{ack: 42, child_node_id: 42, msg_type: 42, node_id: 42, payload: "some content", subtype: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Packet.changeset(%Packet{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Packet.changeset(%Packet{}, @invalid_attrs)
    refute changeset.valid?
  end
end
