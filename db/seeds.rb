emails = ["a@a.a", "b@b.b", "c@c.c", "d@d.d", "e@e.e"]

# This just destroy the specific test users, not the whole DB
puts "Destroying test users"
emails.each do |email|
  puts " ... #{email}"
  User.find_by(email: email).try(:destroy)
end

# This just destroy the specific test events, not the whole DB
puts "Destroying test events"
Event.find_by(location: "Mile End, Montreal",  date: "2022-12-04", rounds: 3).try(:destroy)
Event.find_by(location: "Hochelaga, Montreal", date: "2022-12-05", rounds: 2).try(:destroy)
Event.find_by(location: "Ottawa",              date: "2022-12-04", rounds: 2).try(:destroy)
Event.find_by(location: "Mile End, Montreal",  date: "2023-05-01", rounds: 3).try(:destroy)
Event.find_by(location: "Laval",               date: "2022-12-12", rounds: 3).try(:destroy)

puts "Creating users"
user_a = User.create!(email: emails[0], password: "123456")
user_b = User.create!(email: emails[1], password: "123456")
user_c = User.create!(email: emails[2], password: "123456")
user_d = User.create!(email: emails[3], password: "123456")
user_e = User.create!(email: emails[4], password: "123456")

puts "Creating events"
event_1 = Event.create!(location: "Mile End, Montreal",  date: "2022-12-04", rounds: 3)
event_2 = Event.create!(location: "Hochelaga, Montreal", date: "2022-12-05", rounds: 2)
event_3 = Event.create!(location: "Ottawa",              date: "2022-12-04", rounds: 2)
event_4 = Event.create!(location: "Mile End, Montreal",  date: "2023-05-01", rounds: 3)
event_5 = Event.create!(location: "Laval",               date: "2022-12-12", rounds: 3)

puts "Creating tournaments"
tourney_1 = Tournament.create!(
  user: user_a,
  event: event_1,
  location: event_1.location,
  date: event_1.date,
  rounds: event_1.rounds
)
tourney_2 = Tournament.create!(
  user: user_a,
  event: event_2,
  location: event_2.location,
  date: event_2.date,
  rounds: event_2.rounds,
  pairing_system: 20
)
tourney_3 = Tournament.create!(
  user: user_b,
  event: event_3,
  location: event_3.location,
  date: event_3.date,
  rounds: event_3.rounds
)

puts "Creating Jackson!"
player_1a = Player.create!(
  name: "Jackson Smylie", rating: 2006, division: 1, crosstables_id: 20032, tournament: tourney_1
)
puts "Creating some scrubs"
player_1b = Player.create!(name: "Player B", rating: 1970, division: 1, tournament: tourney_1)
player_1c = Player.create!(name: "Player C", rating: 1100, division: 2, tournament: tourney_1)
player_1d = Player.create!(name: "Player D", rating: 1250, division: 2, tournament: tourney_1)

# These matchups don't follow Swiss pairing. This is just to help test the view
puts "Creating matchups for tournament 1"
matchup1 = Matchup.create!(player1: player_1a, player2: player_1b, round_number: 1)
matchup2 = Matchup.create!(player1: player_1c, player2: player_1d, round_number: 1)
matchup3 = Matchup.create!(player1: player_1a, player2: player_1c, round_number: 2)
matchup4 = Matchup.create!(player1: player_1b, player2: player_1d, round_number: 2)
matchup5 = Matchup.create!(player1: player_1a, player2: player_1d, round_number: 3)
matchup6 = Matchup.create!(player1: player_1b, player2: player_1c, round_number: 3)
