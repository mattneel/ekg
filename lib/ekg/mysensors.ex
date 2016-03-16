defmodule Ekg.MySensors do
require Logger
use GenServer
alias Ekg.Packet

@baud_rate 115_200

def start_link(opts, process_opts \\ []) do
    GenServer.start_link(__MODULE__, opts, process_opts)
end

def command( pid \\ __MODULE__, %{} = packet), do: GenServer.cast(pid, {:command, packet})
def reset( pid \\ __MODULE__), do: GenServer.cast(pid, :reset)

def init(opts) do
    Logger.debug "MySensors initializing..."
    tty = Keyword.fetch!(opts, :tty)
    {:ok, serial} = Serial.start_link()
    Serial.set_speed(serial, @baud_rate)
    Serial.open(serial, tty)
    Serial.connect(serial)
    Logger.debug "Opened serial port."
    {:ok, %{serial: serial}}
end

def handle_info({:elixir_serial, _serial, data}, state) do
	# Parse MySensors packet
	packet = do_mysensors_parse(data)
    # Generate Ecto changeset
    changeset = Packet.changeset(%Packet{}, packet)
    # Do Repo insert
    Repo.insert(changeset)
    
    # Return
    {:noreply, state}
end

def handle_cast({:command, %{} = packet}, %{serial: device} = state) do
    send_message(device, packet)
    {:noreply, state}
end

defp send_message(serial, %{} = packet) do
	Serial.send_data(serial, do_mysensors_encode(packet))
end

defp do_mysensors_parse(data) do
	# Example string: 12;6;0;0;3;My Light\n
	[a, b, c, d, e, f]  = String.split(String.strip(data), ";")
	%{"node_id" => a, "child_sensor_id" => b, "msg_type" => c, "ack" => d, "subtype" => e, "payload" => f}
end

defp do_mysensors_encode(%{} = packet) do
	%{node_id: packet.node_id, child_sensor_id: packet.child_sensor_id, msg_type: packet.msg_type, ack: packet.ack, subtype: packet.subtype, payload: [packet.payload | "\n"]}
end	


end