module CrosstablesFetcher

  BASE_URL = "https://www.cross-tables.com/"

  # Hold event data scraped from the main page
  Event = Struct.new(:xtables_id, :location, :date)

  module_function

  # ---------------------------------------
  # Main entry points to download and parse data

  def get_all_naspa_events
    doc = fetch_main_page()
    events = extract_naspa_events(doc)
    events.map do |ev|
      ev_doc = fetch_entrants_page(ev.xtables_id)
      event = extract_event(ev_doc)
      event.update(ev.to_h)
    end
  end

  def get_players(event_id)
    doc = fetch_entrants_page(event_id)
    extract_players(doc)
  end

  # Grabs the player's pic based on the player's xtables ID
  def get_player_photo(player_id)
    doc = fetch_player_page(player_id)
    photo_path = extract_photo_path(doc)
    URI.open(photo_path)
  end

  # ---------------------------------------
  # Fetch pages from cross-tables.com

  def fetch_url(relative_url)
    url = "#{BASE_URL}/#{relative_url}"
    html = URI.open(url)
    doc = Nokogiri::HTML(html)
  end

  def fetch_main_page
    fetch_url("")
  end

  def fetch_entrants_page(event_id)
    fetch_url("entrants.php?u=#{event_id}")
  end

  def fetch_player_page(player_id)
    fetch_url("results.php?p=#{player_id}")
  end

  # ---------------------------------------
  # Scrape data from pages

  def extract_players(doc)
    data = doc.css('tr.headerrow ~ tr')
    division = 1  # Will be overwriten if there's an explicit division
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

  def extract_photo_path(doc)
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

    photo_path
  end

  def extract_naspa_events(doc)
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
          url = event.attribute('href').value
          xtables_id = url[/\d+$/].to_i
          events << Event.new(xtables_id, location, sortable_date)
        end
      end
    end
    events
  end

  def extract_event(doc)
    number_of_players = doc.css('p').children[8].text.to_i
    rounds = doc.css('td').children.text[/games:.\d*/][/\d+/]
    divisions = 1
    doc.css('td').children.each do |line|
      if line.text[/^Division \d/]
        divisions = line.text[/ [123456789]/].chomp.to_i
      end
    end

    event = {
      rounds: rounds,
      number_of_players: number_of_players,
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
