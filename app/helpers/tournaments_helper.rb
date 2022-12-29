module TournamentsHelper

  def signed(number)
    # TODO: move this somewhere more global
    number >= 0 ? "+#{number}" : number.to_s
  end

  def display_record(player)
    "#{number_to_human(player.win_count)} - #{number_to_human(player.loss_count)}"
  end

  def display_score(result)
    "#{result.score} - #{result.opponent_score} vs. #{result.opponent.name}"
  end

  def display_matchup(result)
    if result.bye?
      "Bye"
    else
      pos = result.started? ? "1st" : "2nd"
      "#{pos} vs. #{result.opponent.name}"
    end
  end

  def display_rating_change(player)
    out = player.rating.to_s
    if player.new_rating
      delta = player.new_rating - player.rating
      out += signed(delta)
    end
    out
  end
    
end
