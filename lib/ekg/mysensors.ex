defmodule Ekg.MySensors do
require Logger
use GenServer
alias Ekg.Packet
alias Ekg.Repo
@baud_rate 115_200

def start_link(opts, process_opts \\ []) do
    tty = Keyword.fetch!(opts, :tty)
    Logger.info "Running Ekg.MySensors using Serial on terminal #{tty}"
    GenServer.start_link(__MODULE__, opts, process_opts)
end

def command( pid \\ __MODULE__, node_id, child_sensor_id, msg_type, ack, subtype, payload), do: GenServer.cast(pid, {:command, node_id, child_sensor_id, msg_type, ack, subtype, payload})
def reset( pid \\ __MODULE__), do: GenServer.cast(pid, :reset)

def init(opts) do
    tty = Keyword.fetch!(opts, :tty)
    {:ok, serial} = Serial.start_link()
    Serial.set_speed(serial, @baud_rate)
    Serial.open(serial, tty)
    Serial.connect(serial)
    {:ok, %{serial: serial}}
end

def handle_info({:elixir_serial, _serial, data}, state) do
	# Parse MySensors packet
	packet = do_mysensors_parse(data)
    # Generate Ecto changeset
    changeset = Packet.changeset(%Packet{}, packet)
    # Do Repo insert
    case Repo.insert(changeset) do
      {:ok, _packet} ->
        Logger.debug "Packet inserted successfully."
      {:error, changeset} ->
        Logger.debug Enum.join(changeset.errors)
    end
    
    # Return
    {:noreply, state}
end

def handle_cast({:command, node_id, child_sensor_id, msg_type, ack, subtype, payload}, %{serial: device} = state) do
    send_message(device, node_id, child_sensor_id, msg_type, ack, subtype, payload)
    {:noreply, state}
end

defp send_message(serial, node_id, child_sensor_id, msg_type, ack, subtype, payload) do
	Serial.send_data(serial, do_mysensors_encode(node_id, child_sensor_id, msg_type, ack, subtype, payload))
end

defp do_mysensors_parse(data) do
	# Example string: 12;6;0;0;3;My Light\n
	[a, b, c, d, e, f]  = String.split(String.strip(data), ";")
	%{"node_id" => a, "child_sensor_id" => b, "msg_type" => c, "ack" => d, "subtype" => e, "payload" => f}
end

defp do_mysensors_encode(node_id, child_sensor_id, msg_type, ack, subtype, payload) do
	%{"node_id" => node_id, "child_sensor_id" => child_sensor_id, "msg_type" => msg_type, "ack" => ack, "subtype" => subtype, "payload" => [payload | "\n"]}
end	


end