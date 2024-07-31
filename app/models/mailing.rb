class Mailing < ApplicationRecord
  belongs_to :client, optional: true
  belongs_to :user, optional: true
  belongs_to :letter

  def self.ransackable_attributes(auth_object = nil)
    %w[user_id letter_id pages color cost created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end
end
