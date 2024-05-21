class User < ApplicationRecord
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Callbacks to assign a default role to a new user
  after_create :assign_default_role

  has_many :clients

  def assign_default_role
    self.add_role(:user) if self.roles.blank?
  end
end
