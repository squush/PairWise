class Tournament < ApplicationRecord
  serialize :pairing_system, JSON
  belongs_to :user
  belongs_to :event, optional: true
  has_many :players, dependent: :destroy
  has_many :matchups, through: :players, source: :matchups_as_player1

  validates :number_of_winners, presence: true
  # TODO: There's still a bug if the user manually clears this field in the form
  #       when creating a new tournament

  # enum pairing_system: {
  #   "Swiss" => 10,
  #   "Round Robin" => 20,
  #   "KOTH" => 30
  # }

  def rounds_to_display
    # Rounds with matchups to display
    (1..self.event.rounds).select do |round|
      round_matchups = self.matchups.for_round(round)
      round_matchups.pending.exists? ||
        round_matchups.count == 0 ||
        round_matchups.inactive.count > 0
    end
  end
end
