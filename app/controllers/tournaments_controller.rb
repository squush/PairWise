require 'nokogiri'
require 'open-uri'
require 'json'

class TournamentsController < ApplicationController
  before_action :set_tournament, only: %i[show]
  skip_before_action :authenticate_user!, only: %i[index show]

  def index
    # all_crosstables_events # Commenting this out so it's not called every page load
    @events = Event.all
    @tournament = Tournament.new
    @tournaments = policy_scope(Tournament)
  end

  def new
    authorize @tournament, policy_class: TournamentPolicy
  end

  def create
    @tournament = Tournament.new(tournament_params)
    @event = Event.find(params[:tournament][:event].to_i)
    @tournament.event = @event
    @tournament.user = current_user

    if @tournament.save!
      redirect_to @tournament, notice: "Tournament has been successfully created"
    else
      render :new, status: :unprocessable_entity
    end

    authorize @tournament, policy_class: TournamentPolicy
  end

  def show
    # raise
  end

  private

  def tournament_params
    params.require(:tournament).permit(:pairing_system, :number_of_winners)
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

  def set_tournament
    @tournament = Tournament.find(params[:id])
    authorize(@tournament)
  end
end
