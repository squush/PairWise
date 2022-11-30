class MatchupsController < ApplicationController
  before_action :set_matchup, only: %i[update]

  def create
    @matchup = Matchup.new(matchup_params)
    @tournament = @matchup.player1.tournament

    if @matchup.save
      redirect_to edit_tournament_path(@tournament)
    else
      render "tournaments/edit", status: :unprocessable_entity
    end

    authorize @matchup, policy_class: MatchupPolicy
  end

  def update
    @matchup.done = true
    if @matchup.update(matchup_params)
      player1 = @matchup.player1
      player2 = @matchup.player2

      if @matchup.player1_score > @matchup.player2_score
        player1.rating += 10
        player2.rating -= 10
      elsif @matchup.player2_score > @matchup.player1_score
        player1.rating -= 10
        player2.rating += 10
      end

      # Update the wins and losses of each player based on the submitted scores
      player1.win_count =
      player1.matchups_as_player1.count { |matchup| matchup.done && (matchup.player1_score > matchup.player2_score) } +
      player1.matchups_as_player2.count { |matchup| matchup.done && (matchup.player2_score > matchup.player1_score) } +
      ((player1.matchups_as_player1.count { |matchup| matchup.done && (matchup.player1_score == matchup.player2_score) } +
      player1.matchups_as_player2.count { |matchup| matchup.done && (matchup.player2_score == matchup.player1_score) }) * 0.5)

      player1.loss_count =
      player1.matchups_as_player1.count { |matchup| matchup.done && (matchup.player1_score < matchup.player2_score) } +
      player1.matchups_as_player2.count { |matchup| matchup.done && (matchup.player2_score < matchup.player1_score) } +
      ((player1.matchups_as_player1.count { |matchup| matchup.done && (matchup.player1_score == matchup.player2_score) } +
      player1.matchups_as_player2.count { |matchup| matchup.done && (matchup.player2_score == matchup.player1_score) }) * 0.5)

      player2.win_count =
      player2.matchups_as_player1.count { |matchup| matchup.done && (matchup.player1_score > matchup.player2_score) } +
      player2.matchups_as_player2.count { |matchup| matchup.done && (matchup.player2_score > matchup.player1_score) } +
      ((player2.matchups_as_player1.count { |matchup| matchup.done && (matchup.player1_score == matchup.player2_score) } +
      player2.matchups_as_player2.count { |matchup| matchup.done && (matchup.player2_score == matchup.player1_score) }) * 0.5)

      player2.loss_count =
      player2.matchups_as_player1.count { |matchup| matchup.done && (matchup.player1_score < matchup.player2_score) } +
      player2.matchups_as_player2.count { |matchup| matchup.done && (matchup.player2_score < matchup.player1_score) } +
      ((player2.matchups_as_player1.count { |matchup| matchup.done && (matchup.player1_score == matchup.player2_score) } +
      player2.matchups_as_player2.count { |matchup| matchup.done && (matchup.player2_score == matchup.player1_score) }) * 0.5)

      # Calculate the player spread by adding their spreads as player1 and as player2
      player1.spread =
      player1.matchups_as_player1.sum { |matchup| matchup.player1_score - matchup.player2_score } +
      player1.matchups_as_player2.sum { |matchup| matchup.player2_score - matchup.player1_score }

      player2.spread =
      player2.matchups_as_player2.sum { |matchup| matchup.player2_score - matchup.player1_score } +
      player2.matchups_as_player1.sum { |matchup| matchup.player1_score - matchup.player2_score }

      player1.save
      player2.save

      # Check if all the scores have been submitted for the round and if so,
      # generate matchups for this division two rounds later
      this_tournament = Tournament.find(player1.tournament_id)
      matchups_without_scores = this_tournament.matchups.where(round_number: @matchup.round_number, done: false).to_a
      matchups_without_scores = matchups_without_scores.select { |matchup| matchup.player1.division == player1.division }


      # Find all players in the division and determine which round to generate
      # pairings for
      players = player1.tournament.players.select { |player| player.division == player1.division}
      round_to_generate = @matchup.round_number + 2
      generate_matchups(round_to_generate, players) if player1.tournament.event.rounds >= round_to_generate && matchups_without_scores.empty?

      redirect_to tournament_matchups_path(@matchup.player1.tournament),
      notice: "matchup #{@matchup.id} was updated."
    else
      # This doesn't work perfectly. Reloads the page, but at least there's no error
      render partial: 'input_score', status: :unprocessable_entity, locals: { matchup: @matchup }
    end
  end

  def index
    @this_tournament = Tournament.find(params[:tournament_id])
    # This order keeps the matchups in order when a score is submitted.
    @all_matchups = @this_tournament.matchups.order(:round_number, :id)

    all_players = Player.where(tournament: @this_tournament)
    divisions = all_players.map { |player| player.division }.uniq.sort

    @matchups = {}
    divisions.each do |div|
      @matchups[div] = @all_matchups.select { |matchup| matchup.player1.division == div }
      Player.where(tournament: @tournament, division: div).order(win_count: :desc, loss_count: :asc, spread: :desc).to_a
    end


    @tournament = policy_scope(Matchup)
    # authorize @tournament, policy_class: MatchupPolicy
    # authorize @matchups, policy_class: MatchupPolicy
  end

  private

  def generate_matchups(round, players)
    # generate pairings
    pairings = Swissper.pair(players, delta_key: :win_count)

    # create matchups based on the pairings
    pairings.each do |pairing|
      if pairing.include?(Swissper::Bye)

        real_player_id = 1 - pairing.find_index(Swissper::Bye)
        if Player.where(tournament: pairing[real_player_id].tournament, name: "Bye").empty?
          bye = Player.create!(name: "Bye", tournament: pairing[real_player_id].tournament, rating: 0, division: div, win_count: 0)
        else
          bye = Player.find_by(tournament: pairing[real_player_id].tournament, name: "Bye")
        end
        Matchup.create!(round_number: round, player1: pairing[real_player_id], player2: bye)
      else
        Matchup.create!(round_number: round, player1: pairing[0], player2: pairing[1])
      end
    end
  end

  def set_matchup
    @matchup = Matchup.find(params[:id])
    authorize @matchup
  end

  # Sanitized parameters
  def matchup_params
    params.require(:matchup).permit(:player1_score, :player2_score)
  end
end
