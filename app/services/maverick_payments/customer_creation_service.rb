require 'httparty'
require 'json'

class MaverickPayments::CustomerCreationService
  include HTTParty
  base_uri 'https://dashboard.maverickpayments.com/api'

  def initialize(attributes = {})
    @attributes = attributes
    @options = {
      headers: {
        'Authorization' => "Bearer #{ENV['MAVERICK_TOKEN_ACCESS']}",
        'Content-Type' => 'application/json'
      },
      body: @attributes.to_json
    }
  end

  def create_customer
    self.class.post('/customer-vault', @options)
  end

  def create_customer_vault_card_form
    self.class.post('/customer-vault-card/form', @options)
  end
end
