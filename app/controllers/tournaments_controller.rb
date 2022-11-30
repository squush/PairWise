require 'nokogiri'
require 'open-uri'
require 'json'
require 'date'

class TournamentsController < ApplicationController
  before_action :set_tournament, only: %i[show edit update destroy]
  skip_before_action :authenticate_user!, only: %i[index show]

  def index
    # all_crosstables_events # Commenting this out so it's not called every page load
    @events = Event.all
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
    @current_round = @tournament.players.first.win_count.to_i + @tournament.players.first.loss_count.to_i
    @current_round += 1 if @current_round.zero?
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
      @players[div] = Player.where(tournament: @tournament, division: div).where.not(name: "Bye").order(win_count: :desc, loss_count: :asc, spread: :desc).to_a
    end

    # @event = Event.find(params[:tournament][:event])c
    authorize @tournament
  end

  def my_tournaments
    @tournaments = Tournament.where(user: current_user)
    authorize @tournaments
  end

  private

  def tournament_params
    params.require(:tournament).permit(:pairing_system, :number_of_winners)
  end

  def get_players(tournament)
    url = "https://www.cross-tables.com/entrants.php?u=#{tournament.event.xtables_id}"
    html = URI.open(url)
    doc = Nokogiri::HTML(html)

    data = doc.css('tr.headerrow ~ tr')
    division = 1
    data.each do |child|
      row = child.search('td').text
      if row.start_with?("Division")
        division = row[/\d/].to_i
      elsif row.start_with?(/\d/)
        seed = row[/\d+/].to_i
        name = child.search('td')[1].text.gsub('*', '').strip[1..-1]
        rating = child.search('td')[2].text.strip
        xtables_id = child.search('td').children.children.css('a').attribute('href').value[/\d{1,5}/]
        if rating == "---"
          rating = 0
        else
          rating = rating.to_i
        end

        player = Player.create!(
          name: name,
          rating: rating,
          division: division,
          seed: seed,
          ranking: seed,
          crosstables_id: xtables_id,
          tournament: tournament
        )

        # The path by default can be either a full path to a photo, for example
        # on scrabbleplayers.org, or a relative path if it's stored directly on
        # cross-tables.
        photo_path = get_player_photo(xtables_id)

        # The gsub is needed because pics with a space in the filename prevent
        # the URI from being opened.
        # TODO: There might be other characters that will break this. Instead of
        #       gsubbing one by one, there might be a cleaner way to fix this.
        photo_path.gsub!(" ", "%20")

        # When the path is relative, we need to create a full URL from it
        if photo_path.start_with?("/")
          photo_path = "https://www.cross-tables.com#{photo_path}"
        end

        user_photo = URI.open(photo_path)
        player.photo.attach(io: user_photo, filename: "player_pic.jpg", content_type: "image/jpg")
        player.save
      end
    end
  end

  # Grabs the source path of the player's pic based on the player's xtables ID
  def get_player_photo(xtables_id)
    url = "https://www.cross-tables.com/results.php?p=#{xtables_id}"
    html = URI.open(url)
    doc = Nokogiri::HTML(html)
    photo = doc.css('img.playerpic')[0][:src]
  end

  def all_crosstables_events
    url = 'https://www.cross-tables.com'
    html = URI.open(url)
    doc = Nokogiri::HTML(html)
    # Find all tags that use the "rowupcoming#" id. This is the CSS id used for
    # each row in the upcoming events table.
    tournaments = doc.xpath('//tr[starts-with(@id, "rowupcoming")]')

    tournaments.each_with_index do |tournament, index|
      # Check if it's a NASPA event
      naspa = tournament.css('img').attribute('src').value == 'i/naspa.png'

      # If it's a NASPA event, get its date and location, and create a new
      # record for that event
      if naspa
        @location = tournament.css('a').children.text

        # May want to use this date method below to get the tournament's start
        # date so that we can sort upcoming events by start date
        # TODO: Fix the month_and_day regex to grab date ranges. Currently,
        #       multi-day events are setting each event on the first day. Check
        #       Kingston, as an example
        month_and_day = tournament.css('td')[-2].children.text[/^\d*\/\d*/]
        year = tournament.css('td')[-2].children.text[/\d{4}/] || Date.today.year
        @sortable_date = Date.parse("#{year}/#{month_and_day}")

        tournament.css('span').children.each do |event|
          create_event(event)
        end
      end
    end
  end

  def create_event(event)
    url = "https://www.cross-tables.com#{event.attribute('href').value}"
    html = URI.open(url)
    doc = Nokogiri::HTML(html)

    # This returns a string date, since often the date is a range,
    # which is not easy to parse into a Date object. See above
    date = doc.css('p').children[2].text[/\w.*20\d\d/]
    xtables_id = event.attribute('href').value[/\d+$/].to_i
    number_of_players = doc.css('p').children[8].text.to_i
    rounds = doc.css('td').children.text[/games:.\d*/][/\d+/]

    Event.create!(
      location: @location,
      rounds: rounds,
      number_of_players: number_of_players,
      date: @sortable_date,
      xtables_id: xtables_id) unless Event.find_by(xtables_id: xtables_id)
  end

  def generate_two_rounds_matchups(tournament)
    # Check how many divisions there are
    all_players = Player.where(tournament: tournament)
    divisions = all_players.map { |player| player.division }.uniq

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
          bye = Player.create!(name: "Bye", tournament: tournament, rating: 0, division: div)
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
