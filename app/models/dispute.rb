class Dispute < ApplicationRecord
  belongs_to :client
  belongs_to :credit_report

  belongs_to :disputable, polymorphic: true
  enum category: { inquiry: 0, account: 1 }

  # validates :bureau, presence: true
  validates :category, presence: true
  serialize :account_details, JSON
  serialize :inquiry_details, JSON
end
