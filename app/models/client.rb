class Client < ApplicationRecord
  belongs_to :user
  has_many :credit_reports
  has_many :disputes

  def self.ransackable_attributes(auth_object = nil)
    %w[name user_id created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end
end
