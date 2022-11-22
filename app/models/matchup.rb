class Matchup < ApplicationRecord
  belongs_to :player1
  belongs_to :player2
  validates :player1_id, :player2_id, presence: true
  validates :round_number, presence: true, numericality: { greater_than_or_equal_to: 1 }
end
