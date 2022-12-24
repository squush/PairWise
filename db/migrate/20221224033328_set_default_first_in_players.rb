class SetDefaultFirstInPlayers < ActiveRecord::Migration[7.0]
  def change
    change_column_default :players, :firsts, from: nil, to: 0
  end
end
