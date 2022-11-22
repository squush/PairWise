class AddDefaultPairingToTournaments < ActiveRecord::Migration[7.0]
  def change
    change_column_default :tournaments, :pairing_system, from: nil, to: 10
  end
end
