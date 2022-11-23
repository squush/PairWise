class TournamentPolicy < ApplicationPolicy
  def index?
    true
  end

  def new?
    create?
  end

  def create?
    true
  end

  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      scope.all
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
