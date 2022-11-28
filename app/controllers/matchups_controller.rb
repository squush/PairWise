class MatchupsController < ApplicationController
  before_action :set_matchup, only: %i[set_score update]

  def create
    @matchup = Matchup.new(matchup_params)
    @tournament = @matchup.player1.tournament

    if @matchup.save!
      redirect_to edit_tournament_path(@tournament)
    else
      render "tournaments/edit", status: :unprocessable_entity
    end

    authorize @matchup, policy_class: MatchupPolicy
  end

  def update
    if @matchup.update(matchup_params)
      # Update the wins and losses of each player based on the submitted scores
      player1 = @matchup.player1
      player2 = @matchup.player2

      if @matchup.player1_score > @matchup.player2_score
        player1.win_count += 1
        player2.loss_count += 1
      elsif @matchup.player1_score < @matchup.player2_score
        player1.loss_count += 1
        player2.win_count += 1
      elsif @matchup.player1_score == @matchup.player2_score
        player1.win_count += 0.5
        player1.loss_count += 0.5
        player2.win_count += 0.5
        player2.loss_count += 0.5
      end

      player1.save!
      player2.save!

      # Check if all the scores have been submitted for the round and if so,
      # generate matchups for this division two rounds later
      this_tournament = Tournament.find(player1.tournament_id)
      matchups_without_scores = this_tournament.matchups.where(round_number: @matchup.round_number, player1_score: nil).to_a
      matchups_without_scores = matchups_without_scores.select { |matchup| matchup.player1.division == player1.division }


      # Find all players in the division and determine which round to generate
      # pairings for
      players = player1.tournament.players.select { |player| player.division == player1.division}
      round_to_generate = @matchup.round_number + 2
      generate_matchups(round_to_generate, players) if player1.tournament.event.rounds >= round_to_generate && matchups_without_scores.empty?

      redirect_to tournament_matchups_path(@matchup.player1.tournament),
                  notice: "matchup #{@matchup.id} was updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def index
    @this_tournament = Tournament.find(params[:tournament_id])
    # This order keeps the matchups in order when a score is submitted.
    @matchups = @this_tournament.matchups.order(:round_number, :id)

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
      Matchup.create!(round_number: round, player1: pairing[0], player2: pairing[1])
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
