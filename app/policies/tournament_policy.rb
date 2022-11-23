class TournamentPolicy < ApplicationPolicy
  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      scope.all
    end

    def index
      true
    end
  end

  # Everyone should be able to see this.
  def show?
    true
  end

  private

  def user_is_owner?
    user == record.user
  end
end
