class Matchup < ApplicationRecord
  belongs_to :player1, class_name: "Player", foreign_key: :player1_id
  belongs_to :player2, class_name: "Player", foreign_key: :player2_id

  # validates :player1_id, uniqueness: { scope: :player2_id }
  validates :round_number, presence: true, numericality: { greater_than: 0 }
  validates :player1_score, presence: true, numericality: { only_integer: true }
  validates :player2_score, presence: true, numericality: { only_integer: true }

  scope :for_player, ->(player) { where(player1: player).or(where(player2: player)) }
  scope :for_round, ->(round) { where(round_number: round) }
  scope :for_division, ->(division) { joins(:player1).where({player1: {division: division}}) }
  scope :complete, -> { where(done: true) }
  scope :pending, -> { where(done: false) }
  # Matchups in (division, round) that are still waiting for scores
  scope :waiting_for_scores, ->(div, round) { for_division(div).for_round(round).pending }
  scope :active, -> { where("player1_score != -50").and(where("player2_score != -50")) }
  scope :inactive, -> { where(player1_score: -50).or(where(player2_score: -50)) }

  def players
    [player1, player2]
  end

  def opponent(player)
    (players - [player])[0]
  end

  def scores
    {player1.id => player1_score, player2.id => player2_score}
  end

  def score(player)
    scores[player.id]
  end

  def bye?
    players.any? {|x| x.bye?}
  end
end
