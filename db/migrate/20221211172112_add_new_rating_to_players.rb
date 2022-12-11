class AddNewRatingToPlayers < ActiveRecord::Migration[7.0]
  def change
    add_column :players, :new_rating, :integer
  end
end
