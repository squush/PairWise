class SetDefaultPairingSystemInTournaments < ActiveRecord::Migration[7.0]
  def change
    change_column_default :tournaments, :pairing_system, from: "10", to: '{"1": ["1", "Swiss"]}'
  end
end
