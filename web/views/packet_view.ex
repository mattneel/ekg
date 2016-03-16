defmodule Ekg.PacketView do
  use Ekg.Web, :view

  def render("index.json", %{packets: packets}) do
    %{data: render_many(packets, Ekg.PacketView, "packet.json")}
  end

  def render("show.json", %{packet: packet}) do
    %{data: render_one(packet, Ekg.PacketView, "packet.json")}
  end

  def render("packet.json", %{packet: packet}) do
    %{id: packet.id,
      node_id: packet.node_id,
      child_node_id: packet.child_node_id,
      msg_type: packet.msg_type,
      ack: packet.ack,
      subtype: packet.subtype,
      payload: packet.payload}
  end
end
