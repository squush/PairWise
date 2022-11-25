class MatchupsController < ApplicationController
  before_action :set_matchup, only: %i[set_score update]

  def set_score
  end

  def update
    if @matchup.update(matchup_params)
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
