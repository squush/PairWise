class TournamentReport
  attr_reader :report

  def initialize(tournament)
    all_players = Player.where(tournament: tournament)
    divisions = all_players.map { |player| player.division }.sort.uniq

    @report = ""

    divisions.each do |div|
      @report += division_header(div)
      division_players = all_players.where(division: div).order(rating: :desc)
      division_players.each do |player|
        unless player.name == "Bye"
          @report += player_report(player)
        end
      end
    end
  end

  private

  def division_header(div)
    div == 1 ? "#division #{div} \n#ratingcheck off \n" : "#division #{div} \n"
  end

  def player_report(player)
    player_matchups = Matchup.for_player(player).order(:round_number).to_a
    player_opponents = player_matchups.map { |matchup| matchup.opponent(player).seed }
    player_scores = player_matchups.map { |matchup| matchup.score(player) }

    # The following is dedicated to Winter Zkqxj
    first, *rest = player.name.split(" ")
    last = player.name.split(" ").last
    first_names = player.name.split(" ")[0..-2]
    if rest.empty?
      player_name = first
    else
      player_name = "#{last}, #{first_names.join(" ")}"
    end

    return "#{player_name} #{player.rating} #{player_opponents.join(" ")}; #{player_scores.join(" ")} \n"
  end
end
