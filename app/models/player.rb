class Player < ApplicationRecord
  belongs_to :tournament
  # The foreign_key in the lines below ensures the destroy works. Otherwise it's
  # looking for just "player_id" by default.
  has_many :matchups_as_player1, class_name: "Matchup", dependent: :destroy, foreign_key: :player1_id
  has_many :matchups_as_player2, class_name: "Matchup", dependent: :destroy, foreign_key: :player2_id

  # TODO: Validation for seed?
  validates :name, :rating, :division, presence: true
  validates :spread, presence: true, numericality: { only_integer: true }
end
