class AddSpreadToPlayers < ActiveRecord::Migration[7.0]
  def change
    add_column :players, :spread, :integer, default: 0
  end
end
