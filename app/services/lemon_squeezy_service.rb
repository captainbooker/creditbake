# app/services/lemon_squeezy_service.rb
require 'net/http'
require 'uri'
require 'json'

class LemonSqueezyService
  BASE_URL = 'https://api.lemonsqueezy.com/v1/'

  def initialize
    @api_key = ENV['LEMON_SQUEEZY_API_KEY']
    @store_id = ENV['LEMON_SQUEEZY_STORE_ID']
  end

  def create_checkout_session(round)
    uri = URI.parse("#{BASE_URL}/checkout")
    request = Net::HTTP::Post.new(uri)
    request.content_type = 'application/json'
    request['Authorization'] = "Bearer #{@api_key}"
    request.body = {
      store_id: @store_id,
      product_id: get_product_id(round),
      success_url: success_url,
      cancel_url: cancel_url
    }.to_json

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.request(request)
    end

    JSON.parse(response.body)
  end

  private

  def get_product_id(round)
    # Map your rounds to Lemon Squeezy product IDs
    {
      1 => 'product_id_for_round_1',
      2 => 'product_id_for_round_2',
      3 => 'product_id_for_round_3'
      # Add mappings for other rounds
    }[round.to_i]
  end

  def success_url
    Rails.application.routes.url_helpers.success_url # Define this route in your routes file
  end

  def cancel_url
    Rails.application.routes.url_helpers.cancel_url # Define this route in your routes file
  end
end
