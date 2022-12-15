require 'crosstables_fetcher'

class TournamentsController < ApplicationController
  before_action :set_tournament, only: %i[show edit update destroy]
  skip_before_action :authenticate_user!, only: %i[index show scoreboard]

  def index
    # all_crosstables_events # Commenting this out so it's not called every page load
    @events = Event.where('date >= ?', Date.today).order(:date)
    @tournament = Tournament.new

    # TODO: Resolve this naming issue. The @tournaments is being taken for the Pundit
    #       policy scope, so we need a different var name for the Tournament.all thing.
    @tournaments = policy_scope(Tournament)
    @pw_tournaments = Tournament.all
  end

  def new
    authorize @tournament, policy_class: TournamentPolicy
  end

  def create
    @tournament = Tournament.new(tournament_params)
    @event = Event.find(params[:tournament][:event].to_i)
    @tournament.event = @event
    @tournament.user = current_user

    get_players(@tournament)
    generate_two_rounds_matchups(@tournament)

    if @tournament.save
      redirect_to tournament_path(@tournament), notice: "Tournament has been successfully created"
    else
      render :new, status: :unprocessable_entity
    end

    authorize @tournament, policy_class: TournamentPolicy
  end

  def show
    @player = Player.new
    @tournament = Tournament.find(params[:id])
    if @tournament.players.any?
      @current_round = @tournament.players.first.win_count.to_i + @tournament.players.first.loss_count.to_i
      @current_round += 1 if @current_round.zero?
    else
      @current_round = 1
    end
  end

  def edit
    @player = Player.new
  end

  def update
    # raise
    if @tournament.update!(tournament_params)
      redirect_to edit_tournament_path(@tournament), notice: "tournament #{@tournament.event.location} was updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @tournament.destroy
    redirect_to my_tournaments_path, notice: "Tournament destroyed!"
  end

  def scoreboard
    @tournament = Tournament.find(params[:id])

    all_players = Player.where(tournament: @tournament)
    divisions = all_players.map { |player| player.division }.uniq.sort

    # Create players hash where each key is a division and
    # each value is an array of the players in that division
    @players = {}
    divisions.each do |div|
      @players[div] = Player.where(
        tournament: @tournament, division: div
      ).where.not(
        name: "Bye"
      ).order(
        win_count: :desc, loss_count: :asc, spread: :desc, rating: :desc
      ).to_a
    end

    # @event = Event.find(params[:tournament][:event])c
    authorize @tournament
  end

  def my_tournaments
    @tournaments = Tournament.where(user: current_user)
    player = Player.where(crosstables_id: current_user.crosstables_id)
    matchups = Matchup.where(player1: player).or(Matchup.where(player1: player))
    @player_tournaments = matchups.map { |matchup| matchup.player1.tournament }.uniq
    authorize @tournaments
  end

  def tournament_report
    File.new "report.txt", "w"
    @tournament = Tournament.find(params[:id])
    all_players = Player.where(tournament: @tournament)
    divisions = all_players.map { |player| player.division }.uniq.sort

    @report = ""

    divisions.each do |div|
      div == 1 ? @report += "#division #{div} \n#ratingcheck off \n" : @report += "#division #{div} \n"
      division_players = all_players.where(division: div)
      division_players.each do |player|
        unless player.name == "Bye"
          player_matchups = Matchup.where(player1: player).or(Matchup.where(player2: player)).to_a
          player_opponents = player_matchups.map { |matchup| matchup.player1 == player ? matchup.player2.seed : matchup.player1.seed }

          player_scores = player_matchups.map { |matchup| matchup.player1 == player ? matchup.player1_score : matchup.player2_score }

          # The following line is dedicated to Winter Zkqxj
          player_name = player.name.split(" ")[1].nil? ? "#{player.name.split(" ")[0]}" : "#{player.name.split(" ")[1..].join(" ")}, #{player.name.split(" ")[0]}"

          @report += "#{player_name} #{player.rating} #{player_opponents.join(" ")}; #{player_scores.join(" ")} \n"
        end
      end
    end

    File.open("report.txt", "w") {
      |f| f.write "#{@report}"
    }

    send_data "#{@report}", :filename => 'report.txt'
    authorize @tournament
  end

  private

  def tournament_params
    params.require(:tournament).permit(:pairing_system, :number_of_winners)
  end

  def get_players(tournament)
    players = CrosstablesFetcher.get_players(tournament.event.xtables_id)
    for p in players do
      player = Player.create!(**p)
      user_photo = CrosstablesFetcher.get_player_photo(player.crosstables_id)
      player.photo.attach(io: user_photo, filename: "player_pic.jpg", content_type: "image/jpg")
      player.save
    end
  end

  def all_crosstables_events
    events = CrosstablesFetcher.get_all_naspa_events
    for event in events do
      # TODO: This hits the db once per event
      unless Event.find_by(xtables_id: event[:xtables_id])
        Event.create!(**event)
      end
    end
  end

  def generate_two_rounds_matchups(tournament)
    # Check how many divisions there are
    all_players = Player.where(tournament: tournament)
    divisions = all_players.map { |player| player.division }.uniq.sort

    # Create players hash where each key is a division and
    # each value is an array of the players in that division
    players = {}
    divisions.each do |div|
      players[div] = Player.where(tournament: tournament).where(division: div).to_a
    end

    # Generate Swissper pairings for the first two rounds
    # for each division
    pairings = {round_1: {}, round_2: {}}
    divisions.each do |div|
      pairings[:round_1][div] = Swissper.pair(players[div], delta_key: :win_count)
      pairings[:round_2][div] = Swissper.pair(players[div], delta_key: :win_count)
    end

    # Generate matchups for round 1 based on pairings
    pairings[:round_1].each do |div, pairings|
      pairings.each do |pairing|
        if pairing.include?(Swissper::Bye)
          real_player_id = 1 - pairing.find_index(Swissper::Bye)
          bye = Player.create!(name: "Bye", tournament: tournament, rating: 0, new_rating: 0, division: div, seed: 0)
          Matchup.create!(round_number: 1, player1: pairing[real_player_id], player2: bye)
        else
          Matchup.create!(round_number: 1, player1: pairing[0], player2: pairing[1])
        end
      end
    end

    # Generate matchups for round 2 based on pairings
    pairings[:round_2].each do |div, pairings|
      pairings.each do |pairing|
        if pairing.include?(Swissper::Bye)
          real_player_id = 1 - pairing.find_index(Swissper::Bye)
          bye = Player.find_by(tournament: tournament, name: "Bye")
          # bye = Player.create!(name: "Bye", tournament: tournament, rating: 0, division: div, win_count: 0)
          Matchup.create!(round_number: 2, player1: pairing[real_player_id], player2: bye)
        else
          Matchup.create!(round_number: 2, player1: pairing[0], player2: pairing[1])
        end

      end
    end
  end

  def set_tournament
    @tournament = Tournament.find(params[:id])
    authorize(@tournament)
  end
end
