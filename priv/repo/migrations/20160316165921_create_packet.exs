defmodule Ekg.Repo.Migrations.CreatePacket do
  use Ecto.Migration

  def change do
    create table(:packets) do
      add :node_id, :integer
      add :child_sensor_id, :integer
      add :msg_type, :integer
      add :ack, :integer
      add :subtype, :integer
      add :payload, :text

      timestamps
    end

  end
end
