class Matchup < ApplicationRecord
  belongs_to :player1, class_name: "Player"  , foreign_key: "player1_id"
  belongs_to :player2, class_name: "Player"  , foreign_key: "player2_id"

  validates :player1_id, uniqueness: { scope: :player2_id }
  validates :round_number, presence: true, numericality: { greater_than: 0 }
end
