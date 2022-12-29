module PairBasic

  # -----------------------------------------------------
  # King of the Hill

  def pair_koth(rp)
    # King of the hill pairing.
    standings = pd.standings_after_round(rp.start_round)
    return standings.each_slice(2)
  end


  # -----------------------------------------------------
  # Queen of the Hill

  def pair_qoth(rp)
    # Queen of the hill pairing.
    standings = pd.standings_after_round(rp.start_round)
    pairings = []
    n = standings.length
    if n % 4 == 2
      last = n - 6
      for i in (0...last).step(4)
        pairings << [standings[i + 0], standings[i + 2]]
        pairings << [standings[i + 1], standings[i + 3]]
        # Pair the last six players 1-4,2-5,3-6 if we don't have a
        # multiple of 4
        pairings << [standings[last + 0], standings[last + 3]]
        pairings << [standings[last + 1], standings[last + 4]]
        pairings << [standings[last + 2], standings[last + 5]]
      end
    else
      for i in (0...n).step(4)
        pairings << [standings[i + 0], standings[i + 2]]
        pairings << [standings[i + 1], standings[i + 3]]
      end
    end
    return pairings
  end


  # -----------------------------------------------------
  # Round Robin

  def _pair_rr(n, r)
    # Pair n players at round r
    init = 1.upto(n).to_a
    h = n / 2
    start = n - 1 - r
    r1 = init[...start]
    r2 = init[start...]
    rotated = [0] + r2 + r1
    h1 = rotated[...h]
    h2 = rotated[h...].reverse
    return [h1, h2]
  end


  def pair_round_robin(rp)
    # Round robin pairing.
    # See https://github.com/domino14/liwords/ for strategy

    standings = pd.standings_after_round(rp.start_round - 1)
    # Pair for game #pos in the round robin
    n = standings.length
    pairings = []
    pos = rp.round - rp.start_round
    h1, h2 = _pair_rr(n, pos)
    for i in 0...(n/2)
      pairings << [standings[h1[i]], standings[h2[i]]]
    end
    return pairings
  end


  # -----------------------------------------------------
  # Charlottesville.

  # Split the field into 2 groups in a snake order.
  # Group 1: 1, 4, 5, 8, 9, 12, 13, 16, 17
  # Group 2: 2, 3, 6, 7, 10, 11, 14, 15, 18
  # For the first 9 rounds, you play a round robin against all the people in the *other* group.

  def pair_charlottesville(rp)
    # Charlottesville pairing
    seeding = pd.standings_after_round(0)
    pos = rp.round
    g1 = []
    g2 = []
    for i in 0...(pd.players.length)
      if i % 4 == 1 or i % 4 == 3
        g1 << i
      else
        g2 << i
      end
    end
    # reverse group 2 so the top player plays the second player last
    g2.reverse!
    # rotate group 2 one place per round and pair up with group 1
    pos = (rp.round - rp.start_round) % g2.length
    r1 = g2[...pos]
    r2 = g2[pos...]
    rotated = r2 + r1
    pairings = []
    g1.each_with_index do |g, i|
      p1 = g
      p2 = rotated[i]
      pairings << [seeding[p1], seeding[p2]]
    end
    return pairings
  end
end
