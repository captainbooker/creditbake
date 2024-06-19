class BureauDetail < ApplicationRecord
  belongs_to :account
  enum bureau: { experian: 0, equifax: 1, transunion: 2 }

  def self.ransackable_attributes(auth_object = nil)
    %w[account_id bureau balance_owed high_credit credit_limit past_due_amount payment_status date_opened date_of_last_payment last_reported created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end
end
