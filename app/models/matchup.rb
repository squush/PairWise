class Matchup < ApplicationRecord
  belongs_to :player1
  belongs_to :player2
  validates :player1_id, :player2_id, presence: true
  validates :round_number, presence: true, numericality: { greater_than_or_equal_to: 1 }
  # belongs_to :player1, class_name: "Player", foreign_key: "player1_id"
  # belongs_to :player2, class_name: "Player", foreign_key: "player2_id"
  belongs_to :tournament, through: :players
end
