defmodule Ekg.PacketControllerTest do
  use Ekg.ConnCase

  alias Ekg.Packet
  @valid_attrs %{ack: 42, child_node_id: 42, msg_type: 42, node_id: 42, payload: "some content", subtype: 42}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, packet_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    packet = Repo.insert! %Packet{}
    conn = get conn, packet_path(conn, :show, packet)
    assert json_response(conn, 200)["data"] == %{"id" => packet.id,
      "node_id" => packet.node_id,
      "child_node_id" => packet.child_node_id,
      "msg_type" => packet.msg_type,
      "ack" => packet.ack,
      "subtype" => packet.subtype,
      "payload" => packet.payload}
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, packet_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, packet_path(conn, :create), packet: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Packet, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, packet_path(conn, :create), packet: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    packet = Repo.insert! %Packet{}
    conn = put conn, packet_path(conn, :update, packet), packet: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Packet, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    packet = Repo.insert! %Packet{}
    conn = put conn, packet_path(conn, :update, packet), packet: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    packet = Repo.insert! %Packet{}
    conn = delete conn, packet_path(conn, :delete, packet)
    assert response(conn, 204)
    refute Repo.get(Packet, packet.id)
  end
end
