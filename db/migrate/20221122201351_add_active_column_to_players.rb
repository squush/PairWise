class AddActiveColumnToPlayers < ActiveRecord::Migration[7.0]
  def change
    add_column :players, :active, :boolean, default: true
  end
end
