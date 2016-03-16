defmodule Ekg.CommandController do
  use Ekg.Web, :controller
  require Ekg.MySensors

  def create(conn, %{"node_id" => node_id, "child_sensor_id" => child_sensor_id, "msg_type" => msg_type, "ack" => ack, "subtype" => subtype, "payload" => payload}) do
 
    Ekg.MySensors.command(:mysensors, node_id, child_sensor_id, msg_type, ack, subtype, payload)
    conn
    |> put_status(:created)
    |> render("show.json", %{status: "OK"})
  end
  
end
