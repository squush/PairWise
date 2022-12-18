class ChangePairingSystemToStringInTournaments < ActiveRecord::Migration[7.0]
  def change
    change_column :tournaments, :pairing_system, :string
  end
end
