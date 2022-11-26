emails = ["a@a.a", "b@b.b", "c@c.c", "d@d.d", "e@e.e"]

# This just destroy the specific test users, not the whole DB
print "Destroying test users: "
emails.each do |email|
  print "... #{email}"
  User.find_by(email: email).try(:destroy)
end
puts ""

# This just destroy the specific test events, not the whole DB
puts "Destroying test events"
Event.find_by(location: "Mile End, Montreal",  date: "2022-12-04", rounds: 3).try(:destroy)
Event.find_by(location: "Hochelaga, Montreal", date: "2022-12-05", rounds: 2).try(:destroy)
Event.find_by(location: "Ottawa",              date: "2022-12-04", rounds: 2).try(:destroy)
Event.find_by(location: "Mile End, Montreal",  date: "2023-05-01", rounds: 2).try(:destroy)
Event.find_by(location: "Laval",               date: "2022-12-12", rounds: 2).try(:destroy)
Event.find_by(location: "Cornwall, Ontario",   date: "2022-12-11", rounds: 2).try(:destroy)

puts "Creating users"
user_a = User.create!(email: emails[0], password: "123456")
user_b = User.create!(email: emails[1], password: "123456")
user_c = User.create!(email: emails[2], password: "123456")

puts "Creating events"
event_1 = Event.create!(location: "Mile End, Montreal",  date: "2022-12-04", rounds: 3)
event_2 = Event.create!(location: "Hochelaga, Montreal", date: "2022-12-05", rounds: 2)
event_3 = Event.create!(location: "Ottawa",              date: "2022-12-04", rounds: 2)
event_4 = Event.create!(location: "Mile End, Montreal",  date: "2023-05-01", rounds: 2)
event_5 = Event.create!(location: "Laval",               date: "2022-12-12", rounds: 2)
event_6 = Event.create!(location: "Cornwall, Ontario",   date: "2022-12-11", rounds: 2)

puts "Creating tournaments"
tourney_1 = Tournament.create!(user: user_a, event: event_1)
tourney_2 = Tournament.create!(user: user_a, event: event_2)
tourney_3 = Tournament.create!(user: user_a, event: event_2)
tourney_4 = Tournament.create!(user: user_a, event: event_2, pairing_system: 20)
tourney_5 = Tournament.create!(user: user_a, event: event_3, pairing_system: 20)
tourney_6 = Tournament.create!(user: user_b, event: event_3)
tourney_7 = Tournament.create!(user: user_c, event: event_3)

print "Creating players for tournament 1... "
print "Jackson! "
player_1a = Player.create!(
  name: "Jackson Smylie", rating: 2006, division: 1, crosstables_id: 20032, tournament: tourney_1
)

player_1a.photo.attach(io: File.open('/assets/images/jack.jpg'), filename: 'jack.jpg', content_type: 'image/jpg')
puts "Plus some scrubs."
player_1b = Player.create!(name: "Player B", rating: 1970, division: 1, tournament: tourney_1)
player_1c = Player.create!(name: "Player C", rating: 1100, division: 2, tournament: tourney_1)
player_1d = Player.create!(name: "Player D", rating: 1250, division: 2, tournament: tourney_1)

# These matchups don't follow Swiss pairing. This is just to help test the view
puts "Creating matchups for tournament 1 (no rounds done)"
Matchup.create!(round_number: 1, player1: player_1a, player2: player_1b)
Matchup.create!(round_number: 1, player1: player_1c, player2: player_1d)
Matchup.create!(round_number: 2, player1: player_1a, player2: player_1c)
Matchup.create!(round_number: 2, player1: player_1b, player2: player_1d)
Matchup.create!(round_number: 3, player1: player_1a, player2: player_1d)
Matchup.create!(round_number: 3, player1: player_1b, player2: player_1c)

puts "Creating players for tournament 2"
player_2a = Player.create!(name: "Player E", rating: 1800, division: 1, tournament: tourney_2)
player_2b = Player.create!(name: "Player F", rating: 1700, division: 1, tournament: tourney_2)
player_2c = Player.create!(name: "Player G", rating: 1700, division: 1, tournament: tourney_2)
player_2d = Player.create!(name: "Player H", rating: 1700, division: 1, tournament: tourney_2)

puts "Creating matchups for tournament 2 (partial round done)"
matchup7 = Matchup.create!(
  round_number: 1,
  player1: player_2a, player1_score: 300,
  player2: player_2b, player2_score: 250
)
Matchup.create!(round_number: 1, player1: player_2c, player2: player_2d)
Matchup.create!(round_number: 2, player1: player_2a, player2: player_2c)
Matchup.create!(round_number: 2, player1: player_2b, player2: player_2d)

puts "Creating players for tournament 3"
player_3a = Player.create!(name: "Player I", rating: 1800, division: 1, tournament: tourney_3)
player_3b = Player.create!(name: "Player J", rating: 1700, division: 1, tournament: tourney_3)
player_3c = Player.create!(name: "Player K", rating: 1500, division: 2, tournament: tourney_3)
player_3d = Player.create!(name: "Player L", rating: 1400, division: 2, tournament: tourney_3)

puts "Creating matchups for tournament 3 (one round done)"
Matchup.create!(
  round_number: 1,
  player1: player_3a, player1_score: 300,
  player2: player_3b, player2_score: 250
)
Matchup.create!(
  round_number: 1,
  player1: player_3c, player1_score: 250,
  player2: player_3d, player2_score: 275
)
Matchup.create!(round_number: 2, player1: player_3b, player2: player_3a)
Matchup.create!(round_number: 2, player1: player_3d, player2: player_3c)

puts "Creating players for tournament 4 (full tournament done)"
player_4a = Player.create!(name: "Player M", rating: 1800, division: 1, tournament: tourney_4)
player_4b = Player.create!(name: "Player N", rating: 1700, division: 1, tournament: tourney_4)
player_4c = Player.create!(name: "Player O", rating: 1500, division: 2, tournament: tourney_4)
player_4d = Player.create!(name: "Player P", rating: 1400, division: 2, tournament: tourney_4)

puts "Creating matchups for tournament 4"
Matchup.create!(
  round_number: 1,
  player1: player_4a, player1_score: 375,
  player2: player_4b, player2_score: 325
)
Matchup.create!(
  round_number: 1,
  player1: player_4c, player1_score: 300,
  player2: player_4d, player2_score: 250
)
Matchup.create!(
  round_number: 2,
  player1: player_4b, player1_score: 400,
  player2: player_4a, player2_score: 390
)
Matchup.create!(
  round_number: 2,
  player1: player_4d, player1_score: 300,
  player2: player_4c, player2_score: 280
)
