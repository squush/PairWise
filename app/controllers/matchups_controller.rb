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
        if !@matchup.bye?
          # Update new rating for each player
          RatingsCalculator.update_ratings(@matchup)
        end

        # Update the wins and losses of each player based on the submitted scores
        player1, player2 = @matchup.players
        player1.recalculate
        player2.recalculate
        player1.save
        player2.save

        # Check if all the scores have been submitted for the round
        this_tournament = Tournament.find(player1.tournament_id)
        div, round = @matchup.player1.division, @matchup.round_number
        matchups_without_scores = this_tournament.matchups.waiting_for_scores(div, round)

        # Confirm that matchups don't exist for this division and round two rounds later
        matchups_in_two_rounds = this_tournament.matchups.waiting_for_scores(div, round + 2)
        matchups_without_scores = ["Don't generate matchups"] unless matchups_in_two_rounds.empty?

        # Only generate matchups if all the current round's scores have been submitted
        if this_tournament.event.rounds >= round_to_generate &&
            matchups_without_scores.empty?
          # Find all players in the division and determine which round to generate
          # pairings for
          players = this_tournament.players.for_division(player1.division).non_bye.to_a
          round_to_generate = round + 2
          generate_matchups(round_to_generate, players)
        end

        redirect_to tournament_matchups_path(this_tournament),
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
    @all_matchups = @all_matchups.reject { |matchup| matchup.player1_score == -50 || matchup.player2_score == -50 }

    all_players = Player.where(tournament: @this_tournament)
    divisions = all_players.map { |player| player.division }.uniq.sort

    @matchups = {}
    divisions.each do |div|
      @matchups[div] = @all_matchups.select { |matchup| matchup.player1.division == div }
      # Player.where(tournament: @tournament, division: div).order(win_count: :desc, loss_count: :asc, spread: :desc).to_a
    end

    @rounds_to_display = []
    (1..@this_tournament.event.rounds).each do |round|
      if @this_tournament.matchups.where(round_number: round, done: false).exists? || @this_tournament.matchups.where(round_number: round).count == 0 || @this_tournament.matchups.where(round_number: round, player1_score: -50).count > 0
        @rounds_to_display << "Round #{round}"
      end
    end


    @tournament = policy_scope(Matchup)
    # authorize @tournament, policy_class: MatchupPolicy
    # authorize @matchups, policy_class: MatchupPolicy
  end

  def matchups_for_round
    @tournament = Tournament.find(params[:id])
    division = params[:division].to_i
    round = params[:round][/\d+/].to_i
    matchups = @tournament.matchups.select { |matchup| matchup.round_number == round }
    matchups.each { |matchup| Matchup.destroy(matchup.id) }

    players = @tournament.players.select { |player| player.division == division && player.name != "Bye"}
    generate_matchups(round, players)

    redirect_to tournament_matchups_path(@tournament)

    authorize @tournament, policy_class: MatchupPolicy
  end

  private

  def generate_matchups(round, players)
    # generate pairings
    active_players = players.select { |player| player.active == true }
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
        Matchup.create!(round_number: round, player1: pairing[0], player2: pairing[1])
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

  def set_matchup
    @matchup = Matchup.find(params[:id])
    authorize @matchup
  end

  # Sanitized parameters
  def matchup_params
    params.require(:matchup).permit(:player1_score, :player2_score)
  end
end
