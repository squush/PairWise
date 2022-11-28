class ChangeWinCountToFloatInPlayers < ActiveRecord::Migration[7.0]
  def change
    change_column :players, :win_count, :float
  end
end
