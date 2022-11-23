require 'nokogiri'
require 'open-uri'

class TournamentsController < ApplicationController
  before_action :set_tournament, only: %i[show]

  def index
    @doc = all_crosstables_events
    @events = Event.all
    # authorize @events
    @tournaments = policy_scope(Tournament)
  end

  def show
    @tournament = Tournament.find(params[:id])
  end

  private

  def all_crosstables_events
    url = 'https://www.cross-tables.com'
    html = URI.open(url)
    doc = Nokogiri::HTML(html)
  end

  def set_tournament
    @tournament = Tournament.find(params[:id])
    authorize(@tournament)
  end
end
