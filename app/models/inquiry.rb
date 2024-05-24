class Inquiry < ApplicationRecord
  has_many :disputes, as: :disputable
  belongs_to :user
end
