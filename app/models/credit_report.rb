class CreditReport < ApplicationRecord
  belongs_to :client, optional: true
  belongs_to :user
  has_one_attached :document
  has_many :disputes
end
