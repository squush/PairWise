module PairQuads
  
  # -------------------
  # Quads

  # We assume there are always an even number of players (one of whom
  # might be 'bye'), but there might not be a divisible-by-four number.
  # If there are 4n+2 players, we divide them into (n-1) quads and a
  # final hex, and pair the hex separately in a group of 3 games.

  # Quad pairings for four players, 0-3
  Pairings4 = [
    [[0, 3], [1, 2]],
    [[0, 2], [1, 3]],
    [[0, 1], [2, 3]]
  ]

  # Incomplete round robin for 6 players, 0-5
  Pairings6 = [
    [[0, 1], [2, 3], [4, 5]],
    [[0, 2], [3, 4], [1, 5]],
    [[0, 3], [1, 4], [2, 5]]
  ]

  def group_position_pairs(group, pos)
    if group.length == 4
      Pairings4[pos - 1]
    else
      Pairings6[pos - 1]
    end
  end

  def pair_groups_at_position(groups, pos)
    pairings = []
    for group in groups
      p = group_position_pairs(group, pos)
      for a, b in p
        pairings << [group[a], group[b]]
      end
    end
    pairings
  end

  def get_last_quad_position(standings)
    n = standings.length
    leftover = n % 4
    if leftover == 0
      return n
    elsif leftover == 2
      return n - 6
    else
      raise StandardError.new("uneven field for quads!")
    end
  end

  def maybe_add_hex(quads, standings, max)
    # we have a leftover hex, add it to the quads
    n = standings.length
    if max < n
      quads << standings[max...n]
    end
  end

  def pairing_quads(rp)
    quads = []
    standings = pd.standings_after_round(rp.start_round)
    max = get_last_quad_position(standings)
    yield [quads, standings, max]
    maybe_add_hex(quads, standings, max)
    pos = rp.round - rp.start_round
    pair_groups_at_position(quads, pos)
  end

  def pair_clustered_quads(rp)
    pairing_quads(rp) do |quads, standings, max|
      for i in (0...max).step(4)
        quads << standings[i...(i + 4)]
      end
    end
  end

  def pair_distributed_quads(rp)
    pairing_quads(rp) do |quads, standings, max|
      stride = max / 4
      0.upto(stride - 1) do |i|
        quads[i] = []
      end
      0.upto(max - 1) do |i|
        quad = i % stride
        quads[quad] << standings[i]
      end
    end
  end

  def pair_evans_quads(rp)
    # Like distributed quads but flip every other subgroup first,
    # so that the sum of opponent seeds ends up roughly equal.
    # e.g. for 12 people you would make quads from
    # 1 2 3 6 5 4 7 8 9 12 11 10
    pairing_quads(rp) do |quads, standings, max|
      stride = max / 4
      0.upto(stride - 1) do |i|
        quads[i] = []
      end
      # Generate new standings snake-style
      new_standings = []
      flip = false
      (0...max).step(stride) do |i|
        slice = standings[i...(i + stride)]
        if flip
          slice.reverse!
          flip = !flip
          new_standings += slice
        end
      end
      # Make quads from the new standings
      0.upto(max - 1) do |i|
        quad = i % stride
        quads[quad] << new_standings[i]
      end
    end
  end
end
