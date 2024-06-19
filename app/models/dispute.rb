class Dispute < ApplicationRecord
  belongs_to :client
  belongs_to :credit_report

  belongs_to :disputable, polymorphic: true
  enum category: { inquiry: 0, account: 1 }

  # validates :bureau, presence: true
  validates :category, presence: true
  serialize :account_details, JSON
  serialize :inquiry_details, JSON

  def self.ransackable_attributes(auth_object = nil)
    %w[client_id credit_report_id bureau account_details inquiry_details payment_status account_rating creditor_type account_status balance_owed date_opened high_balance closed_date account_description dispute_status creditor_remarks payment_amount last_payment term_length past_due_amount account_type open payment_frequency credit_limit date_of_last_activity date_reported last_verified last_reported_on address account_number inquiry_date category disputable_type disputable_id created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end
end
