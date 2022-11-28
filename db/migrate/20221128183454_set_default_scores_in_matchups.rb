class SetDefaultScoresInMatchups < ActiveRecord::Migration[7.0]
  def change
    change_column_default :matchups, :player1_score, from: nil, to: 0
    change_column_default :matchups, :player2_score, from: nil, to: 0
  end
end
