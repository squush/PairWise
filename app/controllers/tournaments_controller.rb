require 'nokogiri'
require 'open-uri'

class TournamentsController < ApplicationController

  # Starting with scraping cross-tables to build an index page for Events
  def index
    @doc = all_crosstables_events
    @events = Event.all
    # authorize @events
    @tournaments = policy_scope(Tournament)
  end

  private

  def all_crosstables_events
    url = 'https://www.cross-tables.com'
    html = URI.open(url)
    doc = Nokogiri::HTML(html)
  end
end
