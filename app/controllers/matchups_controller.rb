class MatchupsController < ApplicationController
  before_action :set_matchup, only: %i[edit]

  def edit
  end

  private

  def set_matchup
    @matchup = Matchup.find(params[:id])
    authorize @matchup
  end
end
