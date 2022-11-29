require 'nokogiri'
require 'open-uri'
require 'date'

# url = "https://www.cross-tables.com/entrants.php?u=15719"
# html = URI.open(url)
# doc = Nokogiri::HTML(html)

# data = doc.css('tr.headerrow ~ tr')
# division = 1

# data.first(1).each do |child|
#   row = child.search('td').text
#   if row.start_with?("Division")
#     division = row[/\d/].to_i
#   elsif row.start_with?(/\d/)
#     seed = row[/\d+/]
#     name = child.search('td')[1].text.strip[1..-1]
#     rating = child.search('td')[2].text.strip
#     xtables_id = child.search('td').children.children.css('a').attribute('href').value[/\d{5}/]
#     if rating == "---"
#       rating = 0
#     else
#       rating = rating.to_i
#     end
#     Player.create!(rating: rating, seed: seed, name: name, ranking: seed, win_count: 0, xtables_id: xtables_id)
#   end
# end

# @players = Player.all
# @players.each do |player|
#   pp player
# end

#   p child.css()
#   if child.css == '.titlerow'
#     p "title row"
#   elsif child.css == 'row1' || child.css == 'row0'
#     pp child.search('td').first.text.match(/\d+/)[0].to_i
#     pp child.search('td')[1].text.strip
#     pp child.search('td')[2].text.strip
#   end

  # pp child.search('td')[3].text.strip
  # pp child.search('td')[4].text.strip
  # pp child.search('td')[5].text.strip
  # pp child.search('td')[6].text.strip
  # pp child.childrentext[/Division \d/]
  # pp child.children.children.css('a').text
  # p child.children.text
  # pp child.children.text[/\d+.  .+  history\n/]
  # pp child.children.text[/^\d+\..*history/]

# url = 'https://www.cross-tables.com'
# html = URI.open(url)
# doc = Nokogiri::HTML(html)
# tournaments = doc.css('#utblock .xtdatatable tr')

# tournaments.each_with_index do |tournament, index|
#   if index.positive? && index < tournaments.count - 2
#     naspa = tournament.css('img').attribute('src').value == 'i/naspa.png'
#     if naspa
#       location = tournament.css('a').children.text
#       # May want to use this date method below to get the tournament's start date
#       # So that we can sort upcoming events by start date
#       month_and_day = tournament.css('td')[-2].children.text[/^\d*\/\d*/]
#       year = tournament.css('td')[-2].children.text[/\d\d\d\d/] || Date.today.year
#       sortable_date = Date.parse("#{year}/#{month_and_day}")

#       tournament.css('span').children.each do |event|
#           url = "https://www.cross-tables.com#{event.attribute('href').value}"
#           html = URI.open(url)
#           doc = Nokogiri::HTML(html)
#           # This returns a string date, since often the date is a range,
#           # which is not easy to parse into a Date object. See above
#           date = doc.css('p').children[2].text[/\w.*202\d/]
#           xtables_id = event.attribute('href').value[/\d\d\d\d\d$/].to_i
#           number_of_players = doc.css('p').children[8].text.to_i
#           number_of_games = doc.css('td').children.text[/games:.\d*/][/\d+/]
#           p date
#           p number_of_players
#           p sortable_date
#       end
#     end
#   end
# end

# url = "https://www.cross-tables.com/results.php?p=#{xtables_id}"


# Testing for player profile pic scraping
ids = ['13509', '580', '7264']

ids.each do |id|
  url = "https://www.cross-tables.com/results.php?p=#{id}"
  html = URI.open(url)
  doc = Nokogiri::HTML(html)

  photo = doc.css('img.playerpic')[0][:src]

  print ""
  pp photo

  if photo.start_with?("/")
    photo = "https://www.cross-tables.com#{photo}"
  end

  pp photo
  pp photo.class
  puts '---'

  user_photo = URI.open(photo)
end
