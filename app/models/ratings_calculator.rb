module RatingsCalculator

  module_function

  def multiplier(rating)
    case rating
    when 2000..3000
      0.5
    when 1800..1999
      0.8
    else
      1
    end
  end

  def change(rating_difference)
    # Apply a rating curve
    case rating_difference.abs
    when 1150..3000; 20
    when 789..1149; 19
    when 611..788; 18
    when 487..610; 17
    when 388..486; 16
    when 305..387; 15
    when 230..304; 14
    when 161..229; 13
    when 96..160; 12
    when 32..95; 11
    when 0..31; 10
    end
  end

  def update_ratings(matchup)
    player1 = matchup.player1
    player2 = matchup.player2
    difference = player1.rating - player2.rating
    p1_multiplier = multiplier(player1.rating)
    p2_multiplier = multiplier(player2.rating)
    change = change(difference)

    if matchup.player1_score > matchup.player2_score
      if difference.positive?
        player1.new_rating += (20 - change) * p1_multiplier
        player2.new_rating -= (20 - change) * p2_multiplier
      else
        player1.new_rating += change * p1_multiplier
        player2.new_rating -= change * p2_multiplier
      end
    elsif matchup.player2_score > matchup.player1_score
      if difference.positive?
        player1.new_rating -= change * p1_multiplier
        player2.new_rating += change * p2_multiplier
      else
        player1.new_rating -= (20 - change) * p1_multiplier
        player2.new_rating += (20 - change) * p2_multiplier
      end
    end
  end

end
