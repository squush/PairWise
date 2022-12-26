module MatchupsGenerator

  def self.generate_matchups(round, players)
    # generate pairings
    active_players = players.select { |player| player.active }
    inactive_players = players.select { |player| player.active == false }
    pairings = Swissper.pair(active_players, delta_key: :win_count)

    # create matchups based on the pairings
    pairings.each do |pairing|
      if pairing.include?(Swissper::Bye)

        real_player_id = 1 - pairing.find_index(Swissper::Bye)
        if Player.where(tournament: pairing[real_player_id].tournament, name: "Bye").empty?
          bye = Player.create!(name: "Bye", tournament: pairing[real_player_id].tournament, rating: 0, new_rating: 0, division: players.first.division, win_count: 0, seed: 0)
        else
          bye = Player.find_by(tournament: pairing[real_player_id].tournament, name: "Bye")
        end
        Matchup.create!(round_number: round, player1: pairing[real_player_id], player2: bye)
      else
        if pairing[0].firsts > pairing[1].firsts
          Matchup.create!(round_number: round, player1: pairing[1], player2: pairing[0])
        elsif pairing[0].firsts < pairing[1].firsts
          Matchup.create!(round_number: round, player1: pairing[0], player2: pairing[1])
        else
          if rand(1..2) == 1
            Matchup.create!(round_number: round, player1: pairing[1], player2: pairing[0])
          else
            Matchup.create!(round_number: round, player1: pairing[0], player2: pairing[1])
          end
        end
        Matchup.last.player1.firsts += 1
      end
    end

    inactive_players.each do |player|
      if Player.where(tournament: player.tournament, name: "Bye").empty?
        bye = Player.create!(name: "Bye", tournament: player.tournament, rating: 0, new_rating: 0, division: player.division, win_count: 0, seed: 0)
      else
        bye = Player.find_by(tournament: player.tournament, name: "Bye")
      end
      Matchup.create!(round_number: round, player1: player, player2: bye, player1_score: -50, player2_score: 0, done: true)
    end

  end

end
