class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)

    if user.has_role?(:admin)
      can :manage, :all
    else
      can :read, :all

      if user.has_role?(:user)
        can :create, Client
        can :update, Client, user_id: user.id
        can :destroy, Client, user_id: user.id
      end
    end
  end
end
