class PlayerResult
  # A matchup from the point of view of one player
  attr_reader :player, :score, :opponent, :opponent_score, :started, :done

  def initialize(matchup, player_number)
    if player_number == 1
      @player = matchup.player1
      @score = matchup.player1_score
      @opponent = matchup.player2
      @opponent_score = matchup.player2_score
      @started = true
      @done = matchup.done
    else
      @player = matchup.player2
      @score = matchup.player2_score
      @opponent = matchup.player1
      @opponent_score = matchup.player1_score
      @started = false
      @done = matchup.done
    end
  end

  def spread
    score - opponent_score
  end

  def wins
    spread > 0 ? 1 : spread == 0 ? 0.5 : 0
  end

  def losses
    1 - wins
  end

  class << self
    def for_player(p)
      results = p.matchups_as_player1.map {|m| PlayerResult.new(m, 1)} +
        p.matchups_as_player2.map {|m| PlayerResult.new(m, 2)}
      results.select {|r| r.done && r.score != -50 && r.opponent.name != "Bye" }
    end
  end

end
