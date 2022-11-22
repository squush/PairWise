class AddSeedToPlayers < ActiveRecord::Migration[7.0]
  def change
    add_column :players, :seed, :integer
  end
end
