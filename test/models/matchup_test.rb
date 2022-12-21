require "test_helper"

class MatchupTest < ActiveSupport::TestCase
  test "basic" do
    t = build(:tournament)
    p1 = build(:player, tournament: t)
    p2 = build(:player, tournament: t)
    m = build(:matchup, player1: p1, player2: p2)
    assert !m.done
  end

  test "bye" do
    p1 = build(:player)
    p2 = build(:bye_player)
    m = build(:matchup, player1: p1, player2: p2)
    assert m.bye?
  end

  test "matchup with scores" do
    t = create(:tournament)
    p1 = create(:player, tournament: t)
    p2 = create(:player, tournament: t)
    m = create(
      :matchup,
      player1: p1,
      player2: p2,
      player1_score: 500,
      player2_score: 400,
      round_number: 1,
      done: true
    )
    assert_equal m.scores, {p1.id => 500, p2.id => 400}
    assert !m.bye?
    assert_equal m.opponent(p1), p2
    assert_equal m.opponent(p2), p1
  end

  test "round in progress" do
    t = create(:tournament)
    p1 = create(:player, tournament: t)
    p2 = create(:player, tournament: t)
    p3 = create(:player, tournament: t)
    p4 = create(:player, tournament: t)
    m1 = create(
      :matchup,
      player1: p1,
      player2: p2,
      player1_score: 500,
      player2_score: 400,
      round_number: 1,
      done: true
    )
    m2 = create(
      :matchup,
      player1: p3,
      player2: p4,
      round_number: 1
    )

    # Matchup queries
    assert m1.done
    assert !m2.done
    assert_equal Matchup.for_player(p1), [m1]
    assert_equal Matchup.for_player(p2), [m1]
    assert_equal Matchup.for_division(1), [m1, m2]
    assert_equal Matchup.waiting_for_scores(1, 1), [m2]

    # Player statistics
    p1.recalculate
    assert_equal p1.win_count, 1.0
    assert_equal p1.loss_count, 0.0
    assert_equal p1.spread, 100
    p2.recalculate
    assert_equal p2.win_count, 0.0
    assert_equal p2.loss_count, 1.0
    assert_equal p2.spread, -100
  end
end
