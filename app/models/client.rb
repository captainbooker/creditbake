class Client < ApplicationRecord
  belongs_to :user
  has_many :credit_reports
  has_many :disputes
end
