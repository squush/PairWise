class Tournament < ApplicationRecord
  serialize :pairing_system, Settings::PairingSystem
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

  def current_round
    (1..self.rounds).each do |round|
      if self.matchups.for_round(round).pending.count > 0
        return round
      end
    end
    p = players.first
    p.win_count.to_i + p.loss_count.to_i + 1
  end

  def division_size(division)
    players.for_division(division).non_bye.count
  end

  def rounds_to_display
    # Rounds with matchups to display
    (1..self.event.rounds).select do |round|
      round_matchups = self.matchups.for_round(round)
      round_matchups.pending.exists? ||
        round_matchups.count == 0 ||
        # May want to remove this later
        round_matchups.inactive.count > 0
    end
  end

  def create_or_retrieve_bye!(division)
    Player.find_by(tournament: self, name: "Bye", division: division) ||
      Player.create!(name: "Bye", tournament: self, rating: 0, new_rating: 0,
                     division: division, win_count: 0, seed: 0)
  end

  def add_new_player(player)
    # Add a new player to this tournament, adding a bye as well if needed.
    div = player.division
    round = current_round
    if division_size(div).odd?
      bye = create_or_retrieve_bye!(div)
      Matchup.create!(round_number: round, player1: player, player2: bye)
      Matchup.create!(round_number: round + 1, player1: player, player2: bye)
    else
      # Find any current bye matches, replace the bye with the new player.
      bye_matchups = matchups.select { |matchup|
        matchup.player2.name == "Bye" && matchup.round_number >= round
      }
      bye_matchups.each do |matchup|
        matchup.player2 = player
        matchup.save
      end
    end
  end

end
