class AdminUser < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :recoverable, :rememberable, :validatable

  attr_encrypted :ssn_last4, key: [ENV['ENCRYPTION_KEY']].pack('H*')
  blind_index :ssn_last4, key: [ENV['ENCRYPTION_KEY']].pack('H*')

  # Define ransackable attributes
  def self.ransackable_attributes(auth_object = nil)
    %w[id email created_at updated_at remember_created_at reset_password_sent_at]
  end

  # Define ransackable associations (optional)
  def self.ransackable_associations(auth_object = nil)
    []
  end
end
