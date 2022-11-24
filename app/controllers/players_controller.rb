class PlayersController < ApplicationController
  before_action :set_tournament, only: %i[create]

  def create
    @player = Player.new(player_params)
    @player.tournament = @tournament

    if @player.save
      redirect_to tournament_path(@tournament)
    else
      render "tournaments/show", status: :unprocessable_entity
    end

    authorize @player
  end

  private

  def set_tournament
    @tournament = Tournament.find(params[:tournament_id])
  end

  def player_params
    params.require(:player).permit(
      :name, :rating, :division, :seed, :ranking, :crosstables_id
    )
  end
end
