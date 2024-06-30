class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :clients
  has_many :inquiries
  has_many :accounts
  has_many :credit_reports
  has_many :letters
  has_many :spendings
  has_many :mailings
  has_many :public_records
  has_many :posts, dependent: :destroy

  has_one_attached :id_document
  has_one_attached :utility_bill
  has_one_attached :additional_document1
  has_one_attached :additional_document2
  has_one_attached :signature
  has_one_attached :avatar

  accepts_nested_attributes_for :accounts, allow_destroy: true, update_only: true
  accepts_nested_attributes_for :clients, allow_destroy: true, update_only: true
  accepts_nested_attributes_for :credit_reports, allow_destroy: true, update_only: true
  accepts_nested_attributes_for :public_records, allow_destroy: true, update_only: true
  accepts_nested_attributes_for :inquiries, allow_destroy: true, update_only: true
  accepts_nested_attributes_for :letters, allow_destroy: true, update_only: true
  accepts_nested_attributes_for :mailings, allow_destroy: true, update_only: true
  accepts_nested_attributes_for :spendings, allow_destroy: true, update_only: true

  attr_encrypted :ssn_last4, key: [ENV['ENCRYPTION_KEY']].pack('H*')
  blind_index :ssn_last4, key: [ENV['ENCRYPTION_KEY']].pack('H*')

  validates :credits, numericality: { greater_than_or_equal_to: 0 }
  validates :free_attack, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validate :password_complexity, on: :create
  validates :agreement, acceptance: true, on: :create
  validate :credits_cannot_be_negative
  validate :free_attack_cannot_be_negative

  before_validation :generate_unique_slug, on: :create

  validates :slug, uniqueness: true
  after_create :send_welcome_email
  after_initialize :grant_free_credit, if: :new_record?
  

  def send_welcome_email
    UserMailer.welcome_email(self).deliver_later
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

  def free_attack
    self[:free_attack] || 0
  end

  # def use_attack
  #   if free_attack > 0
  #     decrement!(:free_attack)
  #   else
  #     decrement!(:credits, 18.99)
  #   end
  # end

  def self.ransackable_attributes(auth_object = nil)
    %w[email phone_number avatar first_name last_name street_address city state postal_code country credits free_attack slug created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end

  private

  def generate_unique_slug
    return if slug.present?

    loop do
      self.slug = SecureRandom.hex(10)
      break unless User.exists?(slug: slug)
    end
  end

  def password_complexity
    if password.present? && !password.match?(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/)
      errors.add :password, 'must be at least 8 characters long, include 1 uppercase letter, 1 lowercase letter, 1 digit, and 1 special character (@, $, !, %, *, ?, &).'
    end
  end

  def credits_cannot_be_negative
    if credits < 0
      errors.add(:credits, "cannot be negative")
    end
  end

  def free_attack_cannot_be_negative
    if free_attack < 0
      errors.add(:free_attack, "cannot be negative")
    end
  end

  def grant_free_credit
    if ENV['ENABLE_FREE_CREDIT'] == 'true'
      self.free_attack += 1
    end
  end
end
