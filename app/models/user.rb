class User < ApplicationRecord
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Callbacks to assign a default role to a new user
  after_create :assign_default_role

  has_many :clients
  has_many :inquiries
  has_many :accounts
  has_many :credit_reports
  has_many :letters

  has_one_attached :id_document
  has_one_attached :utility_bill

  attr_encrypted :ssn_last4, key: ENV['ENCRYPTION_KEY']
  blind_index :ssn_last4

  def assign_default_role
    self.add_role(:user) if self.roles.blank?
  end
end