class CreditReport < ApplicationRecord
  belongs_to :client
  has_one_attached :document
  has_many :disputes
end
