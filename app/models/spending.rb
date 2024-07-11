class Spending < ApplicationRecord
  belongs_to :client, optional: true
  belongs_to :user, optional: true

  before_create :generate_token

  private

  def generate_token
    self.token = SecureRandom.hex(10)
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[user_id amount description token created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end
end
