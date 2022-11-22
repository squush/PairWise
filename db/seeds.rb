# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

# TODO: Figure out how to get this working with the dependent: :destroy association.
#       Currently using that causes an error because (I think) the matchups have
#       two foreign keys to the players table. Probably need a ticket.
Matchup.destroy_all
Player.destroy_all
Tournament.destroy_all
User.destroy_all
Event.destroy_all

puts "Creating users"
# if User.first.nil?
  user_a = User.create!(email: "a@a.a", password: "123456")
  user_b = User.create!(email: "b@b.b", password: "123456")
  user_c = User.create!(email: "c@c.c", password: "123456")
  user_d = User.create!(email: "d@d.d", password: "123456")
  user_e = User.create!(email: "e@e.e", password: "123456")
# else
#   user_a = User.all[0]
#   user_b = User.all[1]
#   user_c = User.all[2]
#   user_d = User.all[3]
#   user_e = User.all[4]
# end

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
