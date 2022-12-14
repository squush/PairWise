class MatchupsController < ApplicationController
  before_action :set_matchup, only: %i[update]
  skip_before_action :authenticate_user!, only: %i[index]

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
    if params[:matchup][:player2]
      @matchup.player2 = Player.find(params[:matchup][:player2])
      @matchup.save
      redirect_to tournament_matchups_path(@matchup.player1.tournament),
      notice: "matchup #{@matchup.id} was updated."
    else
      @matchup.done = true
      if @matchup.update(matchup_params)
        player1 = @matchup.player1
        player2 = @matchup.player2

        # Update new rating for each player
        if @matchup.player1.name != "Bye" && @matchup.player2.name != "Bye"
          difference = player1.rating - player2.rating
          case player1.rating
          when 2000..3000
            p1_multiplier = 0.5
          when 1800..1999
            p1_multiplier = 0.8
          else
            p1_multiplier = 1
          end

          case player2.rating
          when 2000..3000
            p2_multiplier = 0.5
          when 1800..1999
            p2_multiplier = 0.8
          else
            p2_multiplier = 1
          end
          # rating_curve = {1150 => 20, 789 => 19, 611 => 18, 487 => 17, 388 => 16, 305 => 15, 230 => 14, 161 => 13, 96 => 12, 32 => 11, 0 => 10}
          case difference.abs
          when 1150..3000
            change = 20
          when 789..1149
            change = 19
          when 611..788
            change = 18
          when 487..610
            change = 17
          when 388..486
            change = 16
          when 305..387
            change = 15
          when 230..304
            change = 14
          when 161..229
            change = 13
          when 96..160
            change = 12
          when 32..95
            change = 11
          when 0..31
            change = 10
          end

          if @matchup.player1_score > @matchup.player2_score
            if difference.positive?
              player1.new_rating += (20 - change) * p1_multiplier
              player2.new_rating -= (20 - change) * p2_multiplier
            else
              player1.new_rating += change * p1_multiplier
              player2.new_rating -= change * p2_multiplier
            end
          elsif @matchup.player2_score > @matchup.player1_score
            if difference.positive?
              player1.new_rating -= change * p1_multiplier
              player2.new_rating += change * p2_multiplier
            else
              player1.new_rating -= (20 - change) * p1_multiplier
              player2.new_rating += (20 - change) * p2_multiplier
            end
          end
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

        # Check if all the scores have been submitted for the round
        this_tournament = Tournament.find(player1.tournament_id)
        matchups_without_scores = this_tournament.matchups.where(round_number: @matchup.round_number, done: false).to_a
        matchups_without_scores = matchups_without_scores.select { |matchup| matchup.player1.division == player1.division }

        # Confirm that matchups don't exist for this division and round two rounds later
        matchups_in_two_rounds = this_tournament.matchups.where(round_number: @matchup.round_number + 2).to_a
        matchups_in_two_rounds = matchups_in_two_rounds.select { |matchup| matchup.player1.division == player1.division }
        matchups_without_scores = ["Don't generate matchups"] unless matchups_in_two_rounds.empty?

        # Find all players in the division and determine which round to generate
        # pairings for
        players = player1.tournament.players.select { |player| player.division == player1.division && player.name != "Bye"}
        round_to_generate = @matchup.round_number + 2

        # Only generate matchups if all the current round's scores have been submitted
        generate_matchups(round_to_generate, players) if player1.tournament.event.rounds >= round_to_generate && matchups_without_scores.empty?

        redirect_to tournament_matchups_path(@matchup.player1.tournament),
        notice: "matchup #{@matchup.id} was updated."
      else
        # This doesn't work perfectly. Reloads the page, but at least there's no error
        render partial: 'input_score', status: :unprocessable_entity, locals: { matchup: @matchup }
      end
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
          bye = Player.create!(name: "Bye", tournament: pairing[real_player_id].tournament, rating: 0, new_rating: 0, division: div, win_count: 0, seed: 0)
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
