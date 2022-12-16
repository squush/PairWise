module CrosstablesFetcher

  BASE_URL = "https://www.cross-tables.com/"

  module_function

  def get_players(xtables_id)
    doc = fetch_url("entrants.php?u=#{xtables_id}")
    data = doc.css('tr.headerrow ~ tr')
    division = 1
    players = []
    data.each do |child|
      td = child.search('td')
      row = td.text
      if row.start_with?("Division")
        division = row[/\d/].to_i
      elsif row.start_with?(/\d/)
        seed = row[/\d+/].to_i
        name = td[1].text.gsub('*', '').strip[1..-1]
        rating = td[2].text.strip
        player_id = td.children.children.css('a').attribute('href').value[/\d{1,5}/]
        if rating == "---"
          rating = 0
        else
          rating = rating.to_i
        end

        players << {
          name: name,
          rating: rating,
          new_rating: rating,
          division: division,
          seed: seed,
          ranking: seed,
          crosstables_id: player_id,
        }
      end
    end
    players
  end

  # Grabs the player's pic based on the player's xtables ID
  def get_player_photo(player_id)
    doc = fetch_url("results.php?p=#{player_id}")
    # The path by default can be either a full path to a photo, for example
    # on scrabbleplayers.org, or a relative path if it's stored directly on
    # cross-tables.
    photo_path = doc.css('img.playerpic')[0][:src]
    # The gsub is needed because pics with a space in the filename prevent
    # the URI from being opened.
    # TODO: There might be other characters that will break this. Instead of
    #       gsubbing one by one, there might be a cleaner way to fix this.
    photo_path.gsub!(" ", "%20")

    # When the path is relative, we need to create a full URL from it
    if photo_path.start_with?("/")
      photo_path = "#{BASE_URL}#{photo_path}"
    end

    user_photo = URI.open(photo_path)
  end

  def get_all_naspa_events
    doc = fetch_url('')
    # Find all tags that use the "rowupcoming#" id. This is the CSS id used for
    # each row in the upcoming events table.
    tournaments = doc.xpath('//tr[starts-with(@id, "rowupcoming")]')

    events = []
    tournaments.each_with_index do |tournament, index|
      # Check if it's a NASPA event
      naspa = tournament.css('img').attribute('src').value == 'i/naspa.png'

      # If it's a NASPA event, get its date and location, and create a new
      # record for that event
      if naspa
        location = tournament.css('a').children.text

        # May want to use this date method below to get the tournament's start
        # date so that we can sort upcoming events by start date
        date = tournament.css('td')[-2].children.text
        sortable_date = make_sortable_date(date)

        tournament.css('span').children.each do |event|
          events << get_event(event, location, sortable_date)
        end
      end
    end
    events
  end

  def fetch_url(relative_url)
    url = "#{BASE_URL}/#{relative_url}"
    html = URI.open(url)
    doc = Nokogiri::HTML(html)
  end

  def get_event(event, location, date)
    doc = fetch_url("#{event.attribute('href').value}")

    xtables_id = event.attribute('href').value[/\d+$/].to_i
    number_of_players = doc.css('p').children[8].text.to_i
    rounds = doc.css('td').children.text[/games:.\d*/][/\d+/]
    divisions = 1
    doc.css('td').children.each do |line|
      if line.text[/^Division \d/]
        divisions = line.text[/ [123456789]/].chomp.to_i
      end
    end

    event = {
      location: location,
      rounds: rounds,
      number_of_players: number_of_players,
      date: date,
      xtables_id: xtables_id,
      divisions: divisions
    }
  end

  def make_sortable_date(str_date)
    # TODO: Fix the month_and_day regex to grab date ranges. Currently,
    #       multi-day events are setting each event on the first day. Check
    #       Kingston, as an example
    month_and_day = str_date[/^\d*\/\d*/]
    year = str_date[/\d{4}/] || Date.today.year
    sortable_date = Date.parse("#{year}/#{month_and_day}")
  end

end
