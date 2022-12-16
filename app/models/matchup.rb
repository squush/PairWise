class Matchup < ApplicationRecord
  belongs_to :player1, class_name: "Player", foreign_key: :player1_id
  belongs_to :player2, class_name: "Player", foreign_key: :player2_id

  # validates :player1_id, uniqueness: { scope: :player2_id }
  validates :round_number, presence: true, numericality: { greater_than: 0 }
  validates :player1_score, presence: true, numericality: { only_integer: true }
  validates :player2_score, presence: true, numericality: { only_integer: true }

  def opponent(player)
    if player1 == player
      player2
    elsif player2 == player
      player1
    else
      nil
    end
  end

  def score(player)
    if player1 == player
      player1_score
    elsif player2 == player
      player2_score
    else
      nil
    end
  end

  class << self
    def for_player(player)
      return where(player1: player).or(where(player2: player)).to_a
    end
  end
end
