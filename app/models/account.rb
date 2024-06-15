class Account < ApplicationRecord
  has_many :disputes, as: :disputable
  has_many :bureau_details, dependent: :destroy
  belongs_to :user
end
