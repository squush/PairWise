module Pairing

  # Output pairing
  Pairing = Struct.new(:player1, :player2, :repeats)

  PlayerStats = Struct.new(
    :name, :wins, :losses, :ties, :score, :spread, :starts
  ) do
    # Cumulative stats for a player

    def bye?
      @name.downcase == "bye"
    end

    def self.make(name)
      self.new(name, 0, 0, 0, 0, 0, 0)
    end

  end


  Result = Struct.new(:name, :score, :opp_score, :start) do
    # A single game result for a player

    def spread
      score - opp_score
    end

  end


  class Results
    # A collection of results
    
    attr_accessor :players, :rounds, :results

    def initialize
      @players = Hash.new { |h, k| h[k] = PlayerStats.make(k) }
      @results = Hash.new { |h, k| h[k] = [] }
      @rounds = Hash.new { |h, k| h[k] = [] }
    end

    def update_player(result)
      p = @players[result.name]
      p.spread += result.spread
      if result.spread > 0
        p.wins += 1
      elsif result.spread == 0
        p.ties += 1
      else
        p.losses += 1
      end
      p.score = p.wins + 0.5 * p.ties
      p.starts += result.start ? 1 : 0
    end

    def update_round(matchup)
      rounds[matchup.round_number] << matchup
    end

    def add_result_from_matchup(matchup)
      p1 = Result.new(
        matchup.player1.name,
        matchup.player1_score,
        matchup.player2_score,
        true
      )
      p2 = Result.new(
        matchup.player2.name,
        matchup.player2_score,
        matchup.player1_score,
        false
      )
      update_player(p1)
      update_player(p2)
      update_round(matchup)
    end

    def standings
      players.values.sort_by {|p| -p.score}
    end

    def last_round
      rounds.keys.max
    end
  end


  class Repeats
    # Repeats tracker

    attr_reader :matches

    def initialize
      @matches = Hash.new(0)
    end

    def add(p1, p2)
      key = [p1, p2].sort
      matches[key] += 1
      matches[key]
    end

    def add_matchup(m)
      add(m.player1.name, m.player2.name)
    end

    def get(p1, p2)
      key = [p1, p2].sort
      matches[key]
    end

  end

  class Starts
    # Starts tracker

    attr_reader :starts, :round_starts

    def initialize(data)
      @round_starts = []
      @starts = Hash.new(0)
    end

    def add(p1, p2, round)
      round_starts[round] ||= {}
      round_start = round_starts[round]
      if p1.bye?
        # bye always starts
        p1_starts = true
      elsif p2.bye?
        p1_starts = false
      else
        starts1, starts2 = starts[p1.name], starts[p2.name]
        if starts1 == starts2
          p1_starts = !round_start[p1.name]
        else
          p1_starts = starts1 < starts2
        end
      end
      if p1_starts
        starts[p1.name] += 1
        round_start[p1.name] = true
        round_start[p2.name] = false
      else
        starts[p2.name] += 1
        round_start[p1.name] = false
        round_start[p2.name] = true
      end
      p1_starts
    end

  end


  class Data
    # Raw data for pairing
    
    attr_reader :matchups, :players, :repeats

    def initialize(tournament)
      @matchups = tournament.matchups.to_a
      @players = tournament.players.to_a
      @player_lookup = {}
      @players.each {|p| @player_lookup[p.name] = p}
      @repeats = Repeats.new
    end

    def seeding
      players.sort_by { |p| -p.rating }
    end

    def results_after_round(round)
      res = Results.new
      matchups.select { |m| m.round_number <= round }.each do |m|
        res.add_result_from_matchup(m)
      end
      res
    end

    def standings_after_round(round)
      if round == 0
        seeding
      else
        results_after_round(round).standings.map {|p| @player_lookup[p.name]}
      end
    end

    def round_status
      # Have all the games in each round been completed?
      n = players.length / 2
      counts = Hash.new(0)
      for m in matchups
        counts[m.round_number] += 1
      end
      counts.transform_values do |v|
        if v == 0
          :empty
        elsif v == n
          :finished
        else
          :partial
        end
      end
    end

  end

end
