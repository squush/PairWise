require_relative '../lib/matchups_generator'

class MatchupsController < ApplicationController
  include MatchupsGenerator
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
        round_to_generate = round + 2
        if this_tournament.event.rounds >= round_to_generate &&
            matchups_without_scores.empty?
          # Find all players in the division and determine which round to generate
          # pairings for
          players = this_tournament.players.for_division(player1.division).active.non_bye.to_a
          MatchupsGenerator.generate_matchups(round_to_generate, players)
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
    if user_signed_in? && @this_tournament.user == current_user
      @all_matchups = @this_tournament.matchups.active.order(:round_number, :id)
    else
      @all_matchups = @this_tournament.matchups.pending.order(:round_number, :id)
    end

    if user_signed_in? && current_user.crosstables_id
      player = @this_tournament.players.where(crosstables_id: current_user.crosstables_id).first
      @player_matchups = @this_tournament.matchups.for_player(player).order(:round_number)
    end

    divisions = @this_tournament.players.map(&:division).uniq.sort

    @matchups = {}
    divisions.each do |div|
      @matchups[div] = @all_matchups.select { |matchup| matchup.player1.division == div }
    end

    @rounds_to_display = @this_tournament.rounds_to_display.map {|round| "Round #{round}"}

    @tournament = policy_scope(Matchup)
    # authorize @tournament, policy_class: MatchupPolicy
    # authorize @matchups, policy_class: MatchupPolicy
  end

  def matchups_for_round
    @tournament = Tournament.find(params[:id])
    division = params[:division].to_i
    round = params[:round][/\d+/].to_i
    matchups = @tournament.matchups.for_round(round)
    matchups.each { |matchup| Matchup.destroy(matchup.id) }

    players = @tournament.players.for_division(division).non_bye
    MatchupsGenerator.generate_matchups(round, players)

    redirect_to tournament_matchups_path(@tournament)

    authorize @tournament, policy_class: MatchupPolicy
  end

  private

  def set_matchup
    @matchup = Matchup.find(params[:id])
    authorize @matchup
  end

  # Sanitized parameters
  def matchup_params
    params.require(:matchup).permit(:player1_score, :player2_score)
  end
end
