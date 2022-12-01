class PlayerPolicy < ApplicationPolicy
  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    # def resolve
    #   scope.all
    # end
  end

  def create?
    user_is_owner?
  end

  def deactivate?
    user_is_owner?
  end

  private

  def user_is_owner?
    user == record.tournament.user
  end
end
