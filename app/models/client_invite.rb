class ClientInvite < ApplicationRecord
  belongs_to :user
  before_create :generate_token

  validates :expires_at, presence: true

  private

  def generate_token
    self.token = SecureRandom.hex(20)
  end
end
