class SetDefaultPairingsInTournaments < ActiveRecord::Migration[7.0]
  def change
    change_column_default :tournaments, :pairing_system, from: '{"1": ["1", "Swiss"]}', to: ''
  end
end
