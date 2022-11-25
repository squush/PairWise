require 'nokogiri'
require 'open-uri'

namespace :batch do
  desc "Scrape cross-tables.com for upcoming tournaments"
  task scrape_xtables: :environment do
    p "starting scrape"
    url = 'https://www.cross-tables.com'
    html = URI.open(url)
    doc = Nokogiri::HTML(html)
    tournaments = doc.css('#utblock .xtdatatable tr')

    tournaments.each_with_index do |tournament, index|
      p "connected to a tournament"
      if index.positive? && index < tournaments.count - 2
        naspa = tournament.css('img').attribute('src').value == 'i/naspa.png'
        if naspa
          @location = tournament.css('a').children.text
          # May want to use this date method below to get the tournament's start date
          # So that we can sort upcoming events by start date
          month_and_day = tournament.css('td')[-2].children.text[/^\d*\/\d*/]
          year = tournament.css('td')[-2].children.text[/\d\d\d\d/] || Date.today.year
          @sortable_date = Date.parse("#{year}/#{month_and_day}")

          p "found a naspa event"
          tournament.css('span').children.each do |event|
            create_event(event)
          end
        end
      end
    end
  end

  def create_event(event)
    p "creating event"
    new_url = "https://www.cross-tables.com#{event.attribute('href').value}"
    p new_url
    html = URI.parse(new_url).read
    p "URI worked"
    doc = Nokogiri::HTML(html)
    # This returns a string date, since often the date is a range,
    # which is not easy to parse into a Date object. See above
    date = doc.css('p').children[2].text[/\w.*20\d\d/]
    xtables_id = event.attribute('href').value[/\d\d\d\d\d$/].to_i
    number_of_players = doc.css('p').children[8].text.to_i
    number_of_games = doc.css('td').children.text[/games:.\d*/][/\d+/]

    Event.create!(location: @location, rounds: number_of_games, number_of_players: number_of_players, date: @sortable_date, xtables_id: xtables_id) unless Event.find_by(xtables_id: xtables_id)
  end

end
