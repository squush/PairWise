class MatchupPolicy < ApplicationPolicy
  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      scope.all
    end
  end

  # def index?
  #   true
  # end

  def create?
    user_is_owner?
  end

  def update?
    user_is_owner_or_competitor?
  end

  def set_score?
    user_is_owner_or_competitor?
  end

  def matchups_for_round?
    user == record.user
  end

  def create_one_matchup?
    user == record.user
  end

  private

  def user_is_owner?
    user == record.player1.tournament.user
  end

  def user_is_owner_or_competitor?
    user == record.player1.tournament.user || user.crosstables_id == record.player1.crosstables_id || user.crosstables_id == record.player2.crosstables_id
  end
end
