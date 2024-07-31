class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)

    can [:new_with_token, :create_with_token], Client
    can :manage, Client, user_id: user.id if user.subscription.present?
  end
end
