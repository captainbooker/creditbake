# app/models/client_profile.rb
class ClientProfile < ApplicationRecord
  belongs_to :client

  has_one_attached :id_document
  has_one_attached :utility_bill

  attr_encrypted :ssn_last4, key: ENV['ENCRYPTION_KEY']
  blind_index :ssn_last4

  def self.ransackable_attributes(auth_object = nil)
    %w[first_name middle_name last_name ssn_last4 email phone client_id created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end
end
