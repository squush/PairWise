require "open-uri"

print "Destroying all tournaments..."
Tournament.destroy_all

# This just destroy the specific test users, not the whole DB
print "Destroying test users: "
User.find_by(email: "test@test.test").try(:destroy)
print "... #{"test@test.test"}"
User.find_by(email: "demo@demo.demo").try(:destroy)
print "... demo@demo.demo"
puts ""

# This just destroy the specific test events, not the whole DB
puts "Destroying test events"
Event.find_by(location: "Scarborough").try(:destroy)
Event.find_by(location: "Vancouver").try(:destroy)
Event.find_by(location: "Hochelaga").try(:destroy)

puts "Creating users"
user_random = User.create!(email: "test@test.test", password: "testtest")
user_us = User.create!(email: "demo@demo.demo", password: "demodemo")

puts "Creating events"
event_1 = Event.create!(location: "Vancouver", date: "2022-12-02", rounds: 6, number_of_players: 4)
event_2 = Event.create!(location: "Hochelaga", date: "2022-12-02", rounds: 8, number_of_players: 4)

puts "Creating tournaments"
tourney_1 = Tournament.create!(user: user_random, event: event_1, pairing_system: 10)
tourney_2 = Tournament.create!(user: user_us, event: event_2, pairing_system: 10)


puts "Plus some scrubs."
player_1a = Player.create!(name: "Chris Cree", rating: 1965, division: 1, crosstables_id: 435, tournament: tourney_1, win_count: 1, loss_count: 1, spread: 39)
player_1a_pic = URI.open("https://www.scrabbleplayers.org/players/c/cree_chris_CM000002.jpg")
player_1a.photo.attach(io: player_1a_pic, filename: "1a.jpg", content_type: "image/jpg")
player_1a.save

player_1b = Player.create!(name: "Michael Early", rating: 1759, division: 1, tournament: tourney_1, crosstables_id: 437, win_count: 1, loss_count: 1, spread: 60)
player_1b_pic = URI.open("https://www.scrabbleplayers.org/players/e/early_michael.jpg")
player_1b.photo.attach(io: player_1b_pic, filename: "1b.jpg", content_type: "image/jpg")
player_1b.save

player_1c = Player.create!(name: "David Nwabor", rating: 1566, division: 1, tournament: tourney_1, crosstables_id: 24056, win_count: 2, loss_count: 0, spread: 36)
player_1c_pic = URI.open("https://www.scrabbleplayers.org/players/n/nwabor_david_AA005783.jpg")
player_1c.photo.attach(io: player_1c_pic, filename: "1c.jpg", content_type: "image/jpg")
player_1c.save

player_1d = Player.create!(name: "April McCarley", rating: 1184, division: 1, tournament: tourney_1, crosstables_id: 463, win_count: 0, loss_count: 2, spread: 135)
player_1d_pic = URI.open("https://www.scrabbleplayers.org/players/m/mccarley_april.jpg")
player_1d.photo.attach(io: player_1d_pic, filename: "1d.jpg", content_type: "image/jpg")
player_1d.save

# These matchups don't follow Swiss pairing. This is just to help test the view
puts "Creating matchups for tournament 1"
Matchup.create!(round_number: 1, player1: player_1a, player2: player_1b, player1_score: 440, player2_score: 390, done: true)
Matchup.create!(round_number: 1, player1: player_1c, player2: player_1d, player1_score: 420, player2_score: 395, done: true)
Matchup.create!(round_number: 2, player1: player_1b, player2: player_1d, player1_score: 480, player2_score: 370, done: true)
Matchup.create!(round_number: 2, player1: player_1c, player2: player_1a, player1_score: 410, player2_score: 399, done: true)
Matchup.create!(round_number: 3, player1: player_1d, player2: player_1a)
Matchup.create!(round_number: 3, player1: player_1c, player2: player_1b)

print "Creating players for tournament 2... "
print "Jackson! "
player_2a = Player.create!(
  name: "Jackson Smylie", rating: 2006, division: 1, tournament: tourney_2, crosstables_id: 20032, win_count: 4, loss_count: 3, spread: 98
)

player_2a_pic = URI.open("https://www.cross-tables.com/pix/jackson.jpeg")
player_2a.photo.attach(io: player_2a_pic, filename: "jack2.jpg", content_type: "image/jpg")
player_2a.save

puts "Plus some scrubs."
player_2b = Player.create!(name: "Cesar Del Solar", rating: 2002, division: 1, tournament: tourney_2, crosstables_id: 13509, win_count: 2, loss_count: 5, spread: -210)
player_2c = Player.create!(name: "Marlon Hill", rating: 1846, division: 1, tournament: tourney_2, crosstables_id: 560, win_count: 5, loss_count: 2, spread: 347)
player_2d = Player.create!(name: "Lisa Odom", rating: 1905, division: 1, tournament: tourney_2, crosstables_id: 731, win_count: 3, loss_count: 4, spread: -235)
player_2b_pic = URI.open("https://www.cross-tables.com/pix/cdelsolar.jpg")
player_2b.photo.attach(io: player_2b_pic, filename: "2b.jpg", content_type: "image/jpg")
player_2b.save
player_2c_pic = URI.open("https://www.cross-tables.com/pix/mhill.png")
player_2c.photo.attach(io: player_2c_pic, filename: "2c.jpg", content_type: "image/jpg")
player_2c.save
player_2d_pic = URI.open("https://www.scrabbleplayers.org/players/o/odom_lisa_3.jpg")
player_2d.photo.attach(io: player_2d_pic, filename: "2d.jpg", content_type: "image/jpg")
player_2d.save

# These matchups don't follow Swiss pairing. This is just to help test the view
puts "Creating matchups for tournament 2"
Matchup.create!(round_number: 1, player1: player_2a, player2: player_2b, player1_score: 439, player2_score: 390, done: true)
Matchup.create!(round_number: 1, player1: player_2c, player2: player_2d, player1_score: 420, player2_score: 390, done: true)
Matchup.create!(round_number: 2, player1: player_2b, player2: player_2d, player1_score: 358, player2_score: 390, done: true)
Matchup.create!(round_number: 2, player1: player_2c, player2: player_2a, player1_score: 501, player2_score: 390, done: true)
Matchup.create!(round_number: 3, player1: player_2d, player2: player_2a, player1_score: 430, player2_score: 390, done: true)
Matchup.create!(round_number: 3, player1: player_2c, player2: player_2b, player1_score: 390, player2_score: 401, done: true)
Matchup.create!(round_number: 4, player1: player_2a, player2: player_2d, player1_score: 480, player2_score: 390, done: true)
Matchup.create!(round_number: 4, player1: player_2c, player2: player_2b, player1_score: 462, player2_score: 390, done: true)
Matchup.create!(round_number: 5, player1: player_2b, player2: player_2d, player1_score: 390, player2_score: 387, done: true)
Matchup.create!(round_number: 5, player1: player_2c, player2: player_2a, player1_score: 344, player2_score: 390, done: true)
Matchup.create!(round_number: 6, player1: player_2d, player2: player_2a, player1_score: 388, player2_score: 390, done: true)
Matchup.create!(round_number: 6, player1: player_2c, player2: player_2b, player1_score: 402, player2_score: 390, done: true)
Matchup.create!(round_number: 7, player1: player_2c, player2: player_2a, player1_score: 491, player2_score: 390, done: true)
Matchup.create!(round_number: 7, player1: player_2d, player2: player_2b, player1_score: 431, player2_score: 390, done: true)
Matchup.create!(round_number: 8, player1: player_2d, player2: player_2a)
Matchup.create!(round_number: 8, player1: player_2c, player2: player_2b)

puts ""
