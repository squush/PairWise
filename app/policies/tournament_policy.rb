class TournamentPolicy < ApplicationPolicy
  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      scope.all
    end
  end

  def index?
    true
  end



  def create?
    true
  end

  # Everyone should be able to see this.
  def show?
    true
  end




  def update?
    user_is_owner?
  end

  def scoreboard?
    true
  end

  def my_tournaments?
    true
  end

  private

  def user_is_owner?
    user == record.user
  end
end
