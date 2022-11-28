class AddLossCountToPlayers < ActiveRecord::Migration[7.0]
  def change
    add_column :players, :loss_count, :float
  end
end
