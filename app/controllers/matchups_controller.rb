class MatchupsController < ApplicationController
  before_action :set_matchup, only: %i[set_score update]

  def set_score
  end

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
      # Update the wins and losses of each player
      # based on the submitted scores
      p1 = @matchup.player1
      p2 = @matchup.player2
      if @matchup.player1_score > @matchup.player2_score
        p1.win_count += 1
        p2.loss_count += 1
      elsif @matchup.player1_score < @matchup.player2_score
        p1.loss_count += 1
        p2.win_count += 1
      else
        p1.win_count += 0.5
        p1.loss_count += 0.5
        p2.win_count += 0.5
        p2.loss_count += 0.5
      end

      p1.save!
      p2.save!

      # Check if all the scores have been submitted
      # for the round and if so, generate matchups
      # for this division two rounds later
      # matchups = Matchup.where(tournament: @matchup.tournament).where(division: @matchup.player1.division).where(round_number: @matchup.round_number).where(player1_score: nil)
      this_tournament = Tournament.find(p1.tournament_id)
      matchups = this_tournament.matchups.where(round_number: @matchup.round_number).where(player1_score: nil).to_a
      matchups.map { |matchup| matchup.player1.division == p1.division }

      # generate matchups...

      redirect_to tournament_matchups_path(@matchup.player1.tournament),
                  notice: "matchup #{@matchup.id} was updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def index
    @this_tournament = Tournament.find(params[:tournament_id])
    @matchups = @this_tournament.matchups

    @tournament = policy_scope(Matchup)
    # authorize @tournament, policy_class: MatchupPolicy
    # authorize @matchups, policy_class: MatchupPolicy
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
