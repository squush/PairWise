require_relative '../lib/matchups_generator'

class Player < ApplicationRecord
  include HasUserPhoto
  include MatchupsGenerator

  belongs_to :tournament
  # The foreign_key in the lines below ensures the destroy works. Otherwise it's
  # looking for just "player_id" by default.
  has_many :matchups_as_player1, class_name: "Matchup", dependent: :destroy, foreign_key: :player1_id
  has_many :matchups_as_player2, class_name: "Matchup", dependent: :destroy, foreign_key: :player2_id
  has_one_attached :photo
  # TODO: Validation for seed?
  validates :name, :rating, :division, presence: true
  validates :spread, presence: true, numericality: { only_integer: true }
  validates :win_count, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :loss_count, presence: true, numericality: { greater_than_or_equal_to: 0 }

  scope :for_division, ->(division) { where(division: division) }
  scope :non_bye, -> { where("name != 'Bye'") }
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }

  def bye?
    name == "Bye"
  end

  def recalculate
    results = PlayerResult.for_player(self)
    self.win_count = results.map(&:wins).sum
    self.loss_count = results.map(&:losses).sum
    self.spread = results.map(&:spread).sum
  end

  def deactivate
    # Set the player to inactive and adjust all pending matchups
    self.active = false

    Matchup.for_player(self).pending.each do |matchup|
      bye = tournament.create_or_retrieve_bye!(division)
      Matchup.create!(round_number: matchup.round_number, player1: self,
                      player2: bye, player1_score: -50, player2_score: 0,
                      done: true)
      if matchup.player1 == self
        matchup.player1 = bye
      else
        matchup.player2 = bye
      end

      if matchup.player1 == bye && matchup.player2 == bye
        matchup.destroy
      else
        matchup.save
      end
    end
  end

  def reactivate
    self.active = true
    self.save

    Matchup.for_player(self).inactive.each do |matchup|
      round = matchup.round_number
      if self.tournament.matchups.for_round(round).active.complete.count == 0
        # Destroy all existing matchups of future rounds and regenerate that round's pairings
        self.tournament.matchups.for_round(round).destroy_all
        players = self.tournament.players.for_division(self.division).active.non_bye.to_a
        MatchupsGenerator.generate_matchups(round, players)
      end
    end
  end

end
