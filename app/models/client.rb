class Client < ApplicationRecord
  belongs_to :user
  has_many :inquiries
  has_many :accounts
  has_many :credit_reports
  has_many :letters
  has_many :spendings
  has_many :mailings
  has_many :public_records
  has_many :personal_informations

  has_one_attached :id_document
  has_one_attached :utility_bill
  has_one_attached :additional_document1
  has_one_attached :additional_document2
  has_one_attached :signature

  def self.ransackable_attributes(auth_object = nil)
    %w[name user_id created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end

  def full_name
    "#{first_name} #{last_name}"
  end
end
