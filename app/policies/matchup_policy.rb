class MatchupPolicy < ApplicationPolicy
  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    # def resolve
    #   scope.all
    # end
  end

  def edit?
    update?
  end

  def update?
    user_is_owner?
  end

  private

  def user_is_owner?
    user == record.player1.tournament.user
  end
end
