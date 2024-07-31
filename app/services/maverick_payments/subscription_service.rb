module MaverickPayments
  class SubscriptionService
    include HTTParty
    base_uri 'https://dashboard.maverickpayments.com/api' # Replace with the actual base URL of your API

    def initialize(user, subscription)
      @user = user
      @subscription = subscription
      @headers = {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{ENV['MAVERICK_TOKEN_ACCESS']}" # Assuming you use Bearer token for auth
      }
    end

    def create_subscription
      body = {
        name: @subscription.name,
        description: @subscription.name,
        amount: @subscription.price,
        execute: {
          frequency: 1,
          period: "month"
        },
        valid: {
          from: (Date.today + 31).strftime("%Y-%m-%d")
        },
        payment: {
          max: nil
        },
        terminal: {
          id: "415304"
        },
        customer: {
          id: @user.maverick_customer_id,
          card: {
            id: @user.maverick_card_id
          }
        },
        dba: {
          id: "190265"
        }
      }.to_json

      response = self.class.post("/customer-vault/#{@user.maverick_customer_id}/recurring-payment", headers: @headers, body: body)
      handle_response(response)
    end

    def cancel_subscription_status(status)
      url = "/customer-vault/#{@user.maverick_customer_id}/recurring-payment/#{@user.maverick_recurring_id}"
      body = { status: status }.to_json

      response = self.class.put(url, headers: @headers, body: body)
      
      if response.success?
        @user.update(maverick_recurring_id: nil, subscription: nil)
        response.parsed_response
      else
        Rollbar.error("Failed to update subscription status", {
          user_id: @user.id,
          subscription_id: @subscription.id,
          response: response.body
        })
        raise "Failed to update subscription status: #{response.body}"
      end
    end

    private

    def handle_response(response)
      if response.success?
        parsed_response = response.parsed_response
        @user.update(maverick_recurring_id: parsed_response["id"])
        parsed_response
      else
        Rollbar.error("Failed to create subscription", {
          user_id: @user.id,
          subscription_id: @subscription.id,
          response: response.body
        })
        raise "Failed to create subscription: #{response.body}"
      end
    end
  end
end
