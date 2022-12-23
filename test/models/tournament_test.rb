require "test_helper"

class TournamentTest < ActiveSupport::TestCase
  test "add new player" do
    t = create(:tournament)
    p1 = create(:player, tournament: t)
    t.add_new_player(p1)
    # Check that we added a bye player and two matchups
    assert_equal t.players.count, 2
    assert_equal t.matchups.count, 2
    assert t.matchups.all? {|m| m.bye?}
    # Now add a second player
    p2 = create(:player, tournament: t)
    t.add_new_player(p2)
    # Check that we did not add a second bye
    assert_equal t.players.count, 3
    # Check that we did not add any new matchups
    assert_equal t.matchups.count, 2
    # Check that the byes got replaced with player2
    refute t.matchups.any? {|m| m.bye?}
    assert t.matchups.all? {|m| m.player2 == p2}
    # Adding a third player should reuse the existing bye player
    p3 = create(:player, tournament: t)
    t.add_new_player(p3)
    assert_equal t.players.count, 4
    # We should have bye matches for player3
    t.matchups.reload
    p3_matches = t.matchups.for_player(p3)
    assert_equal p3_matches.count, 2
    assert p3_matches.all? {|m| m.bye?}
  end

  test "deactivate player" do
    t = create(:tournament)
    p1 = create(:player, tournament: t)
    t.add_new_player(p1)
    p2 = create(:player, tournament: t)
    t.add_new_player(p2)
    # p1 has been matched against p2
    p1_matches = t.matchups.for_player(p1)
    refute p1_matches.any? {|m| m.bye?}
    # when we deactivate p2 all p1's matches should be byes
    p2.deactivate
    p1_matches = t.matchups.for_player(p1)
    assert p1_matches.all? {|m| m.bye?}
  end
end
