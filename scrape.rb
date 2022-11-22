require 'nokogiri'
require 'open-uri'

url = 'https://www.cross-tables.com'
html = URI.open(url)
doc = Nokogiri::HTML(html)
return doc
