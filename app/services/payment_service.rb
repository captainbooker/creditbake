require 'httparty'
require 'rollbar'

class PaymentService
  include HTTParty
  base_uri 'https://gateway.maverickpayments.com'

  def initialize(payment_id)
    @payment_id = payment_id
    @auth_token = ENV["MAVERICK_TOKEN_ACCESS"]
  end

  def fetch_payment_details
    response = self.class.get(
      "/payment/#{@payment_id}",
      headers: {
        "Authorization" => "Bearer #{@auth_token}",
        "User-Agent" => "Ruby",
        "Accept" => "*/*",
        "Accept-Encoding" => "gzip, deflate, br",
        "Connection" => "keep-alive"
      }
    )

    if response.success?
      parse_response(response)
    else
      handle_error(response)
    end
  rescue StandardError => e
    Rollbar.error(e)
    { error: 'An error occurred while processing the request' }
  end

  private

  def parse_response(response)
    body = JSON.parse(response.body)
    {
      status: body.dig('status', 'status'),
      amount: body['amount'].to_f
    }
  end

  def handle_error(response)
    Rollbar.error("Failed to fetch payment details", response: response.body)
    { error: 'Failed to fetch payment details' }
  end
end
