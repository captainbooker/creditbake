require 'httparty'
require 'json'

module MaverickPayments
  class RecurringService
    include HTTParty
    base_uri 'https://dashboard.maverickpayments.com/api'

    def initialize(user)
      @user = user
      @customer_id = @user.maverick_customer_id
      @card_id = @user.maverick_card_id
      @dba_id = "190265"
      @terminal_id = "415304"
      @options = {
        headers: {
          'Authorization' => "Bearer #{ENV['MAVERICK_PAYMENTS_API_TOKEN']}",
          'Content-Type' => 'application/json'
        }
      }
    end

    def create_recurring_payment
      body = {
        name: "Monthly subscription",
        description: "Cinema Membership",
        amount: 3,
        execute: {
          frequency: 1,
          period: "month"
        },
        valid: {
          from: "2020-01-01",
          to: "2020-12-31"
        },
        payment: {
          max: 12
        },
        terminal: {
          id: @terminal_id
        },
        customer: {
          id: @customer_id,
          card: {
            id: @card_id
          }
        },
        dba: {
          id: @dba_id
        }
      }

      self.class.post("/customer-vault/#{@customer_id}/recurring-payment", @options.merge(body: body.to_json))
    end
  end
end
