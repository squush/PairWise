require 'minitest'
require 'nokogiri'
require 'crosstables_fetcher'


DATA_DIR = "#{__dir__}/testdata"
MAIN_PAGE = "#{DATA_DIR}/crosstables-index.html"
ENTRANTS_PAGE = "#{DATA_DIR}/crosstables-entrants-15744.html"
PLAYER_PAGE = "#{DATA_DIR}/crosstables-results-70.html"


def doc(path)
  Nokogiri::HTML(IO.read(path))
end


class TestCrosstablesFetcher < MiniTest::Test

  def test_extract_naspa_events
    main_doc = doc(MAIN_PAGE)
    events = CrosstablesFetcher.extract_naspa_events(main_doc)
    ev = events.first
    assert_equal ev.xtables_id, 15744
    assert_equal ev.location, "Conshohocken, PA"
    assert_equal ev.date.to_s, "2022-12-17"
  end

  def test_extract_event
    entrants_doc = doc(ENTRANTS_PAGE)
    ev = CrosstablesFetcher.extract_event(entrants_doc)
    assert_equal ev, {
      rounds: "7",
      number_of_players: 14,
      divisions: 2
    }
  end

  def test_extract_players
    entrants_doc = doc(ENTRANTS_PAGE)
    players = CrosstablesFetcher.extract_players(entrants_doc)
    pl = players.first
    assert_equal pl, {
      name: "Mark Miller",
      rating: 1699,
      new_rating: 1699,
      division: 1,
      seed: 1,
      ranking: 1,
      crosstables_id: "70"
    }
  end

  def test_extract_photo_path
    player_doc = doc(PLAYER_PAGE)
    photo_path = CrosstablesFetcher.extract_photo_path(player_doc)
    assert_equal photo_path, "https://www.scrabbleplayers.org/players/m/miller_mark.jpg"
  end

end
