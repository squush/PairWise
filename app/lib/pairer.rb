# The main entry point for round pairing.
# Usage:
#   pairer = Pairer.new(tournament)
#   pairings = pairer.pair
#
# Returns an array of
#   [[round number, pairings], ...]
# for all pairable rounds, where pairings is itself an array of
#   [Pairing::Pairing(player1, player2, repeats), ...]
#
# The Pairer will contain statistics of starts and repeats in `pairer.starts`
# and `pairer.pd.repeats` respectively.
#
# Individual pairing strategies can be found in the PairBasic etc modules, and
# are implemented as methods named `pair_*`, which should take in a
# RoundPairing and return an array of [[player1, player2], ...] for that round.

class Pairer
  include PairBasic
  include PairQuads
  include PairSwiss

  attr_reader :round_pairings, :pd, :status, :starts

  def initialize(tournament)
    @pd = Pairing::Data.new(tournament)
    @round_pairings = tournament.pairing_system.round_pairings
    @status = @pd.round_status
    @starts = Pairing::Starts.new(@pd)
  end

  def pair
    ret = []
    round_pairings[1..].each do |rp|
      if status[rp.round] == :finished
        process_finished_round(rp)
      else
        pairings = process_pending_round(rp)
        ret << [rp.round, pairings]
      end
    end
    ret
  end

  private

  def pair_round(rp)
    return [] unless can_pair(rp)
    strategy = self.method("pair_#{rp.strategy}")
    strategy.call(rp)
  end

  def can_pair(rp)
    if status[rp.round] == :finished
      false
    elsif [:round_robin, :charlottesville].include?(rp.strategy)
      # Round robins do not depend on results from a previous round
      true
    else
      rp.start_round == 0 || status[rp.start_round] == :finished
    end
  end

  def process_finished_round(rp)
    # Collect repeats for finished rounds
    matchups = pd.matchups.select {|m| m.round_number == rp.round}
    matchups.each do |m|
      pd.repeats.add_matchup(m)
    end
  end

  def process_pending_round(rp)
    pairings = []
    for p1, p2 in pair_round(rp)
      reps = pd.repeats.add(p1.name, p2.name)
      p1_starts = starts.add(p1, p2, rp.round)
      if p1_starts
        pairings << Pairing::Pairing.new(p1, p2, reps)
      else
        pairings << Pairing::Pairing.new(p2, p1, reps)
      end
    end
    pairings
  end

end
