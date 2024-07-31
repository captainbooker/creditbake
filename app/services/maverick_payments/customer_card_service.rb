# app/services/maverick_payments/customer_card_service.rb

require 'httparty'

module MaverickPayments
  class CustomerCardService
    include HTTParty
    base_uri 'https://dashboard.maverickpayments.com/api'

    def initialize(user)
      @user = user
    end

    def fetch_card
      response = self.class.get("/customer-vault/#{@user.maverick_customer_id}/card/#{@user.maverick_card_id}", headers: { 'Content-Type' => 'application/json', 'Authorization' => "Bearer #{ENV['MAVERICK_TOKEN_ACCESS']}" })
      handle_response(response)
    end

    private

    def handle_response(response)
      if response.success?
        data = response.parsed_response
        @user.update!(maverick_card_token: data['token'])
      else
        Rollbar.error("Failed to fetch card: #{response.body}")
      end
    end
  end
end
