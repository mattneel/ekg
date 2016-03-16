defmodule Ekg.PacketController do
  use Ekg.Web, :controller

  alias Ekg.Packet

  plug :scrub_params, "packet" when action in [:create, :update]

  def index(conn, _params) do
    packets = Repo.all(Packet)
    render(conn, "index.json", packets: packets)
  end

  def create(conn, %{"packet" => packet_params}) do
    changeset = Packet.changeset(%Packet{}, packet_params)

    case Repo.insert(changeset) do
      {:ok, packet} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", packet_path(conn, :show, packet))
        |> render("show.json", packet: packet)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Ekg.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    packet = Repo.get!(Packet, id)
    render(conn, "show.json", packet: packet)
  end

  def update(conn, %{"id" => id, "packet" => packet_params}) do
    packet = Repo.get!(Packet, id)
    changeset = Packet.changeset(packet, packet_params)

    case Repo.update(changeset) do
      {:ok, packet} ->
        render(conn, "show.json", packet: packet)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Ekg.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    packet = Repo.get!(Packet, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(packet)

    send_resp(conn, :no_content, "")
  end
end
