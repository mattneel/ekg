defmodule Ekg.SensorsChannel do
    require Logger
  use Ekg.Web, :channel

  def join("sensors:lobby", payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

def handle_in("new_msg", %{"node_id" => node_id, "child_sensor_id" => child_sensor_id, "msg_type" => msg_type, "ack" => ack, "subtype" => subtype, "payload" => payload}, socket) do
    Logger.debug "Broadcasting new_msg: #{node_id};#{child_sensor_id};#{msg_type};#{ack};#{subtype};#{payload}"
    broadcast socket, "new_msg", %{"node_id" => node_id, "child_sensor_id" => child_sensor_id, "msg_type" => msg_type, "ack" => ack, "subtype" => subtype, "payload" => payload}
    {:noreply, socket}
end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # This is invoked every time a notification is being broadcast
  # to the client. The default implementation is just to push it
  # downstream but one could filter or change the event.
  def handle_out(event, payload, socket) do
    push socket, event, payload
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
