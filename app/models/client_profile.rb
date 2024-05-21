# app/models/client_profile.rb
class ClientProfile < ApplicationRecord
  belongs_to :client

  has_one_attached :id_document
  has_one_attached :utility_bill

  attr_encrypted :ssn_last4, key: ENV['ENCRYPTION_KEY']
  blind_index :ssn_last4
end
