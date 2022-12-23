class PlayersController < ApplicationController
  before_action :set_tournament, only: %i[create]

  def create
    @player = Player.new(player_params)
    @player.tournament = @tournament

    unless @player.crosstables_id.nil?
      user_photo = CrosstablesFetcher.get_player_photo(@player.crosstables_id)
      @player.attach_photo(user_photo)
    end

    if @player.save
      @tournament.add_new_player(@player)
      redirect_to edit_tournament_path(@tournament)
    else
      render 'tournaments/edit', status: :unprocessable_entity
    end

    authorize @player
  end

  def deactivate
    @player = Player.find(params[:id])
    @player.deactivate
    if @player.save
      redirect_to edit_tournament_path(@player.tournament)
    else
      render 'tournaments/edit', status: :unprocessable_entity
    end
    authorize @player
  end

  def reactivate
    @player = Player.find(params[:id])
    @player.active = true
    if @player.save
      redirect_to edit_tournament_path(@player.tournament)
    else
      render 'tournaments/edit', status: :unprocessable_entity
    end

    authorize @player
  end

  private

  def set_tournament
    @tournament = Tournament.find(params[:tournament_id])
  end

  def player_params
    params.require(:player).permit(
      :name, :rating, :division, :seed, :ranking, :crosstables_id, :new_rating
    )
  end

end
