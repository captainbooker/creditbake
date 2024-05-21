class Account < ApplicationRecord
  has_many :disputes, as: :disputable
  has_many :bureau_details
end
