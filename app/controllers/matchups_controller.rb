class MatchupsController < ApplicationController
  before_action :set_matchup, only: %i[edit update]

  def edit
  end

  def update
    if @matchup.update(matchup_params)
      redirect_to tournament_path(@matchup.player1.tournament),
        notice: "matchup #{@matchup.id} was updated."
    else
      render :edit, status: :unprocessable_entity
    end
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
