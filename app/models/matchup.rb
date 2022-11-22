class Matchup < ApplicationRecord
  belongs_to :player1
  belongs_to :player2
  # belongs_to :player1, class_name: "Player", foreign_key: "player1_id"
  # belongs_to :player2, class_name: "Player", foreign_key: "player2_id"
  belongs_to :tournament, through: :players
end
