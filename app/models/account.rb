class Account < ApplicationRecord
  has_many :disputes, as: :disputable
  has_many :bureau_details, dependent: :destroy
  belongs_to :user

  def self.ransackable_attributes(auth_object = nil)
    %w[account_number account_type account_type_detail account_status challenge creditor_name name created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end
end
