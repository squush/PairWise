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

  def new?
    create?
  end

  def create?
    true
  end

  # Everyone should be able to see this.
  def show?
    true
  end

<<<<<<< HEAD
  def scoreboard?
=======
  def my_tournaments?
>>>>>>> 03f184c5bed1f293a6849600ba164d090e88289f
    true
  end

  private

  def user_is_owner?
    user == record.user
  end
end
