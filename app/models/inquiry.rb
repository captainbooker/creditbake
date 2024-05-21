class Inquiry < ApplicationRecord
  has_many :disputes, as: :disputable
end
