class PublicRecord < ApplicationRecord
  has_many :bureau_details, dependent: :destroy
  belongs_to :user
end
  