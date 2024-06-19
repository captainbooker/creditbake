class Inquiry < ApplicationRecord
  has_many :disputes, as: :disputable
  belongs_to :user

  def self.ransackable_attributes(auth_object = nil)
    %w[inquiry_name type_of_business inquiry_date credit_bureau challenge user_id address created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end
end
