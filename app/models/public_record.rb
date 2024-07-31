class PublicRecord < ApplicationRecord
  has_many :bureau_details, dependent: :destroy
  belongs_to :client, optional: true
  belongs_to :user, optional: true
end
  