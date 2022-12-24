class AddFirstsToPlayers < ActiveRecord::Migration[7.0]
  def change
    add_column :players, :firsts, :integer
  end
end
