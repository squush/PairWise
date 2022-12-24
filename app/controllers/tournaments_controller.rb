require_relative '../lib/crosstables_fetcher'

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

    # round_number_selected = @tournament.pairing_system["round"]
    pairing_system_selected = params[:tournament][:pairing_system]["pairing"]
    @tournament.pairing_system = Settings::PairingSystem.new([])
    @tournament.pairing_system.add_round_pairing(1, 0, pairing_system_selected)

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
    @rounds_to_display = []
    (1..@tournament.event.rounds).each do |round|
      if @tournament.matchups.where(round_number: round, done: false).exists? || @tournament.matchups.where(round_number: round).count == 0
        @rounds_to_display << "Round #{round}"
      end
    end
  end

  def update
    new_pairings = @tournament.pairing_system
    new_key = @tournament.pairing_system.keys.max.to_i + 1
    new_pairings[new_key] = [params[:tournament][:pairing_system]["round"], params[:tournament][:pairing_system]["pairing"]]
    new_pairings.delete("round")
    new_pairings.delete("pairing")
    if @tournament.update!(pairing_system: new_pairings, number_of_winners: params[:tournament][:number_of_winners])
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

    @current_round = @tournament.players.first.win_count.to_i + @tournament.players.first.loss_count.to_i
    @current_round += 1 if @current_round.zero?

    # @event = Event.find(params[:tournament][:event])c
    authorize @tournament
  end

  def my_tournaments
    @tournaments = Tournament.where(user: current_user)
    if user_signed_in? && current_user.crosstables_id
      @player_tournaments = current_user.tournaments_as_player
    end

    authorize @tournaments
  end

  def tournament_report
    @tournament = Tournament.find(params[:id])
    @report = TournamentReport.new(@tournament).report
    File.open("report.txt", "w") do |f|
      f.write @report
    end

    send_data @report, :filename => 'report.txt'
    authorize @tournament
  end

  private

  def tournament_params
    params.require(:tournament).permit(:number_of_winners)
  end

  def get_players(tournament)
    players = CrosstablesFetcher.get_players(tournament.event.xtables_id)
    for p in players do
      player = Player.create!(tournament: tournament, **p)
      user_photo = CrosstablesFetcher.get_player_photo(player.crosstables_id)
      player.attach_photo(user_photo)
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
