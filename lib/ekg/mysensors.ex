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
	Logger.debug "Incoming packet: #{data}"
    # Parse MySensors packet
	packet = parse(data)
    if (packet) do
        # Generate Ecto changeset
        changeset = Packet.changeset(%Packet{}, packet)
        # Do Repo insert
        case Repo.insert(changeset) do
        {:ok, _packet} ->
            Logger.debug "Packet inserted successfully."
            Ekg.Endpoint.broadcast!("sensors:lobby", "new_msg", packet)
        {:error, _changeset} ->
            Logger.debug "Invalid packet: #{data}"
        end
    end
    # Return
    {:noreply, state}
end

def parse([node_id, child_sensor_id, msg_type, ack, subtype, payload]) do
        %{:node_id => node_id,
        :child_sensor_id => child_sensor_id,
        :msg_type => msg_type,
        :ack => ack,
        :subtype => subtype,
        :payload => payload}    
end
    
def parse(data) do
    if (length(String.split(data, ";")) == 6) do
        data |> String.strip |> String.split(";") |> parse
    end
end

def handle_cast({:command, node_id, child_sensor_id, msg_type, ack, subtype, payload}, %{serial: device} = state) do   
	data = packet_to_string(parse([node_id, child_sensor_id, msg_type, ack, subtype, payload]))
    Logger.debug "Sending: #{data}"
    Serial.send_data(device, data)
    {:noreply, state}
end

defp packet_to_string(%{:node_id => node_id, :child_sensor_id => child_sensor_id, :msg_type => msg_type, :ack => ack, :subtype => subtype, :payload => payload}) do
    "#{node_id};#{child_sensor_id};#{msg_type};#{ack};#{subtype};#{payload}\n"
end

end