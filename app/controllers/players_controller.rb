class PlayersController < ApplicationController
  before_action :set_tournament, only: %i[create]

  def create
    @player = Player.new(player_params)
    @player.tournament = @tournament

    unless @player.crosstables_id.nil?
      user_photo = get_player_photo(@player.crosstables_id)
      @player.photo.attach(io: user_photo, filename: "player_pic.jpg", content_type: "image/jpg")
    end

    if @player.save
      current_round = @tournament.players.first.win_count.to_i + @tournament.players.first.loss_count.to_i + 1
      division_size = @tournament.players.count { |player| player.division == @player.division && player.name != "Bye" }
      if division_size.odd?
        bye = Player.create!(name: "Bye", tournament: @tournament, rating: 0, division: @player.division, win_count: 0)
        Matchup.create!(round_number: current_round, player1: @player, player2: bye)
        Matchup.create!(round_number: current_round + 1, player1: @player, player2: bye)
      else
        # find which player has a bye
        matchups = @tournament.matchups.select { |matchup| matchup.player2.name == "Bye" && matchup.round_number >= current_round }
        matchups.each do |matchup|
          matchup.player2 = @player
          matchup.save
        end
      end

      Matchup.create()
      redirect_to edit_tournament_path(@tournament)
    else
      render 'tournaments/edit', status: :unprocessable_entity
    end

    authorize @player
  end

  def deactivate
    @player = Player.find(params[:id])
    @player.active = false
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

  # Grabs the source path of the player's pic based on the player's xtables ID
  def get_player_photo(xtables_id)
    url = "https://www.cross-tables.com/results.php?p=#{xtables_id}"
    html = URI.open(url)
    doc = Nokogiri::HTML(html)
    photo = doc.css('img.playerpic')[0][:src]
    photo.gsub!(" ", "%20")
    if photo.start_with?("/")
      photo = "https://www.cross-tables.com#{photo}"
    end
    URI.open(photo)
  end
end
