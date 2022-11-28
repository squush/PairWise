class SetDefaultWinsAndLossesToPlayers < ActiveRecord::Migration[7.0]
  def change
    change_column_default :players, :win_count, from: nil, to: 0
    change_column_default :players, :loss_count, from: nil, to: 0
  end
end
