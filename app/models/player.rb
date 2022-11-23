class Player < ApplicationRecord
  belongs_to :tournament
  # The foreign_key in the lines below ensures the destroy works. Otherwise it's
  # looking for just "player_id" by default.
  has_many :player1_matchups, class_name: "Matchup", dependent: :destroy, foreign_key: :player1_id
  has_many :player2_matchups, class_name: "Matchup", dependent: :destroy, foreign_key: :player2_id

  # TODO: Validation for seed?
  validates :name, :rating, :division, presence: true
end
