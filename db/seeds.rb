require "open-uri"

emails = ["a@a.a", "b@b.b"]

# This just destroy the specific test users, not the whole DB
print "Destroying test users: "
User.find_by(email: emails[0]).try(:destroy)
print "... #{emails[0]}"
User.find_by(email: emails[1]).try(:destroy)
print "... #{emails[1]}"
puts ""

# This just destroy the specific test events, not the whole DB
puts "Destroying test events"
Event.find_by(location: "Mile End, Montreal", date: "2022-12-04").try(:destroy)
Event.find_by(location: "Laval",              date: "2022-12-07").try(:destroy)
Event.find_by(location: "Ottawa",             date: "2022-12-10").try(:destroy)

puts "Creating users"
user_a = User.create!(email: emails[0], password: "123456")
user_b = User.create!(email: emails[1], password: "123456")

puts "Creating events"
event_1 = Event.create!(location: "Mile End, Montreal", date: "2022-12-04", rounds: 3)
event_2 = Event.create!(location: "Laval",              date: "2022-12-07", rounds: 3)
event_3 = Event.create!(location: "Ottawa",             date: "2022-12-10", rounds: 5)

puts "Creating tournaments"
tourney_1 = Tournament.create!(user: user_a, event: event_1)
tourney_2 = Tournament.create!(user: user_a, event: event_2, pairing_system: 20)
tourney_3 = Tournament.create!(user: user_b, event: event_3)

print "Creating players for tournament 1... "
print "Jackson! "
player_1a = Player.create!(
  name: "Jackson Smylie", rating: 2006, division: 1, crosstables_id: 20032, tournament: tourney_1
)

player_1a_pic = URI.open("https://www.cross-tables.com/pix/IMG_1335.jpg")
player_1a.photo.attach(io: player_1a_pic, filename: "jack1.jpg", content_type: "image/jpg")
player_1a.save

puts "Plus some scrubs."
player_1b = Player.create!(name: "Michael Early", rating: 1759, division: 1, tournament: tourney_1, crosstables_id: 437)
player_1c = Player.create!(name: "David Nwabor", rating: 1566, division: 1, tournament: tourney_1, crosstables_id: 24056)
player_1d = Player.create!(name: "April McCarley", rating: 1184, division: 1, tournament: tourney_1, crosstables_id: 463)
player_1b_pic = URI.open("https://www.scrabbleplayers.org/players/e/early_michael.jpg")
player_1b.photo.attach(io: player_1b_pic, filename: "1b.jpg", content_type: "image/jpg")
player_1b.save
player_1c_pic = URI.open("https://www.scrabbleplayers.org/players/n/nwabor_david_AA005783.jpg")
player_1c.photo.attach(io: player_1c_pic, filename: "1c.jpg", content_type: "image/jpg")
player_1c.save
player_1d_pic = URI.open("https://www.scrabbleplayers.org/players/m/mccarley_april.jpg")
player_1d.photo.attach(io: player_1d_pic, filename: "1d.jpg", content_type: "image/jpg")
player_1d.save

# These matchups don't follow Swiss pairing. This is just to help test the view
puts "Creating matchups for tournament 1"
Matchup.create!(round_number: 1, player1: player_1a, player2: player_1b)
Matchup.create!(round_number: 1, player1: player_1c, player2: player_1d)
Matchup.create!(round_number: 2, player1: player_1b, player2: player_1d)
Matchup.create!(round_number: 2, player1: player_1c, player2: player_1a)

print "Creating players for tournament 2... "
print "Jackson! "
player_2a = Player.create!(
  name: "Jackson Smylie", rating: 2006, division: 1, tournament: tourney_2, crosstables_id: 20032
)

player_2a_pic = URI.open("https://www.cross-tables.com/pix/IMG_1335.jpg")
player_2a.photo.attach(io: player_2a_pic, filename: "jack2.jpg", content_type: "image/jpg")
player_2a.save

puts "Plus some scrubs."
player_2b = Player.create!(name: "Michael Early", rating: 1759, division: 1, tournament: tourney_2, crosstables_id: 437)
player_2c = Player.create!(name: "David Nwabor", rating: 1566, division: 1, tournament: tourney_2, crosstables_id: 24056)
player_2d = Player.create!(name: "April McCarley", rating: 1184, division: 1, tournament: tourney_2, crosstables_id: 463)
player_2b_pic = URI.open("https://www.scrabbleplayers.org/players/e/early_michael.jpg")
player_2b.photo.attach(io: player_2b_pic, filename: "2b.jpg", content_type: "image/jpg")
player_2b.save
player_2c_pic = URI.open("https://www.scrabbleplayers.org/players/n/nwabor_david_AA005783.jpg")
player_2c.photo.attach(io: player_2c_pic, filename: "2c.jpg", content_type: "image/jpg")
player_2c.save
player_2d_pic = URI.open("https://www.scrabbleplayers.org/players/m/mccarley_april.jpg")
player_2d.photo.attach(io: player_2d_pic, filename: "2d.jpg", content_type: "image/jpg")
player_2d.save

# These matchups don't follow Swiss pairing. This is just to help test the view
puts "Creating matchups for tournament 2"
Matchup.create!(round_number: 1, player1: player_2a, player2: player_2b)
Matchup.create!(round_number: 1, player1: player_2c, player2: player_2d)
Matchup.create!(round_number: 2, player1: player_2b, player2: player_2d)
Matchup.create!(round_number: 2, player1: player_2c, player2: player_2a)

puts ""
