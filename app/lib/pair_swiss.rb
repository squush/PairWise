require 'graph_matching'

module PairSwiss

  Candidate = Struct.new(:repeats, :distance, :name1, :name2)

  Pair = Struct.new(:name1, :name2, :repeats)

  class Groups
    attr_reader :groups

    def initialize(n)
      @groups = (0..n).map { [] }
    end

    def to_s
      @groups.map {|g| g.map {|p| "#{p.name}: #{p.win_count}"}}.to_s
    end

    def self.from_standings(standings)
      max_wins = standings.map(&:win_count).max
      ret = Groups.new(max_wins)
      for p in standings
        ret.groups[p.win_count] << p
      end
      ret.compact!
      ret.groups.reverse!
      # balance groups
      ret.balance!
      ret.compact!
      return ret 
    end

    def length
      groups.length
    end

    def empty?
      groups.empty?
    end

    def top
      groups.first
    end

    def bottom
      groups.last
    end

    def compact!
      groups.reject!(&:empty?)
    end

    def balance!
      groups.each_cons(2) do |cur, nxt|
        if cur.length.odd?
          fst = nxt.shift
          cur << fst
        end
      end
    end

    def promote!(i, j)
      fst = groups[j].shift
      groups[i] << fst
    end

    def promote2!(i)
      j = i + 1
      promote(i, j)
      if groups[j].empty?
        promote(i, j + 1)
      else
        promote(i, j)
      end
    end

    def merge_bottom!
      # Merge the last two groups
      return if groups.length == 1
      last = groups.pop
      groups.last.concat(last)
    end
  end  # class Groups


  def _pair_swiss_initial(standings)
    pairings = []
    half = standings.length / 2
    0.upto(half - 1) do |i|
      pairings << [standings[i], standings[i + half]]
    end
    pairings
  end

  def _pair_swiss_top(groups, repeats, nrep)
    top = groups.top
    candidates = []
    0.upto(top.length - 1) do |i|
      candidates[i] = []
      0.upto(top.length - 1) do |j|
        next if i == j
        reps = repeats.get(top[i].name, top[j].name)
        if reps < nrep
          c = Candidate.new(reps, (i - j).abs, top[j].name, top[i].name)
          candidates[i] << c
        end
        for c in candidates
          c.sort_by! {|x| [x.repeats, x.distance]}
        end
      end
    end
    candidates
  end

  def generate_matching(edges)
    # All the weights need to be positive
    m = edges.map(&:last).min || 0
    edges = edges.map {|v1, v2, w| [v1, v2, w - m] }
    g = GraphMatching::Graph::WeightedGraph[*edges]
    g.maximum_weighted_matching(true).edges
  end

  def _pair_candidates(bracket)
    edges = []
    names = {}
    inames = {}
    # Generate graph with integer vertices for the graph matching library
    bracket.each.with_index do |player_candidates, i|
      name = player_candidates[0].name2
      names[name] = i + 1
      inames[i + 1] = name
    end

    for player_candidates in bracket
      for c in player_candidates
        # don't pair candidates too far apart
        if c.distance < 11
          weight = -(30 * c.repeats + c.distance)
          v1 = names[c.name1]
          v2 = names[c.name2]
          edges << [v1, v2, weight]
        end
      end
    end

    generate_matching(edges).map do |v1, v2|
      name1 = inames[v1]
      name2 = inames[v2]
      Pair.new(name1, name2, 0)
    end
  end

  def pair_swiss(rp)
    if rp.start_round < 1
      return _pair_swiss_initial(pd.seeding)
    end

    players = pd.standings_after_round(rp.start_round)
    names = {}
    players.each {|p| names[p.name] = p}
    groups = Groups.from_standings(players)
    nrep = 1
    paired = []

    # Don't have too small a bottom group
    if groups.length > 1
      while groups.bottom.length < 6 && groups.length > 1
        groups.merge_bottom!
      end
    end

    while groups.length > 0
      candidates = _pair_swiss_top(groups, pd.repeats, nrep)
      if candidates.any?(&:empty?)
        if groups.length == 1
          nrep += 1
          next
        end
        groups.compact!
        groups.promote2!(0)
        groups.compact!
        if groups.length == 1
          nrep += 1
          next
        end
      else
        pairs = _pair_candidates(candidates)
        groups.compact!
        if pairs.length != candidates.length / 2
          # We have an unpaired candidate; increase the rep count
          nrep += 1
          break if groups.length == 1
          next
        end
        groups.groups.shift
        paired << pairs
        break if groups.empty?
      end
    end
    out = []
    for group in paired
      for p in group
        out << p
      end
    end
    out.map {|p| [names[p.name1], names[p.name2]]}
  end
end
