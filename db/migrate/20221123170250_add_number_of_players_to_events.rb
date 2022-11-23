class AddNumberOfPlayersToEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :number_of_players, :integer
  end
end
