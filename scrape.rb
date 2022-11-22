require 'nokogiri'
require 'open-uri'

url = 'https://www.cross-tables.com'
html = URI.open(url)
doc = Nokogiri::HTML(html)
tournaments = doc.css('#utblock .xtdatatable tr')

tournaments.first(2).each_with_index do |tournament, index|
  if index.positive?
    # naspa = tournament.css('span').children.first.attribute('href').value
    naspa = tournament.css('img').attribute('src').value == 'i/naspa.png'
    url = "https://www.cross-tables.com#{tournament.css('span').children.first.attribute('href').value}"
    # pp tournament
    city = tournament.css('a').children.text
    # pp city
    # tournament.css('span').children.first.attribute('href').value
    date = tournament.css('td').children.text
    number_of_players = 0
    # pp tournament
    pp date

  end
end

#pp tournaments[1].css('span').children.first.attribute('href').value


# want: naspa?, city, date, # of players, href
