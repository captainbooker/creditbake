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
  has_many :spendings
  has_many :mailings

  has_one_attached :id_document
  has_one_attached :utility_bill
  has_one_attached :additional_document1
  has_one_attached :additional_document2
  has_one_attached :signature

  attr_encrypted :ssn_last4, key: [ENV['ENCRYPTION_KEY']].pack('H*')
  blind_index :ssn_last4, key: [ENV['ENCRYPTION_KEY']].pack('H*')


  validates :credits, numericality: { greater_than_or_equal_to: 0 }
  validate :password_complexity, on: :create

  def assign_default_role
    self.add_role(:user) if self.roles.blank?
  end

  def log_spending(amount, description)
    spendings.create(amount: amount, description: description)
    decrement!(:credits, amount)
  end

  def initials
    first_initial = first_name.present? ? first_name[0].upcase : ""
    last_initial = last_name.present? ? last_name[0].upcase : ""
    "#{first_initial}#{last_initial}"
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def credits
    self[:credits] || 0
  end

  private

  def password_complexity
    if password.present? && !password.match?(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/)
      errors.add :password, 'must be at least 8 characters long, include 1 uppercase letter, 1 lowercase letter, 1 digit, and 1 special character (@, $, !, %, *, ?, &).'
    end
  end
end
