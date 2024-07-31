# app/services/maverick_payments/payment_service.rb

require 'httparty'

module MaverickPayments
  class PaymentService
    include HTTParty
    base_uri 'https://gateway.maverickpayments.com'

    def initialize(user, subscription)
      @options = {
        body: {
          terminal: { id: "415304" },
          amount: subscription.price,
          source: 'Internet',
          level: 1,
          card: {
            token: user.maverick_card_token
          },
          contact: { email: user.email },
          sendReceipt: 'Yes'
        }.to_json,
        headers: { 'Content-Type' => 'application/json', 'Authorization' => "Bearer #{ENV["MAVERICK_TOKEN_ACCESS"]}" }
      }
    end

    def process_payment
      self.class.post('/payment/sale', @options)
    end
  end
end
