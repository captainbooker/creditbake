require 'net/http'
require 'uri'
require 'json'

class ChatGPTService
  BASE_URL = "https://api.openai.com/v1"

  def initialize(api_key)
    @api_key = api_key
  end

  def parse_credit_report(document_content)
    uri = URI.parse("#{BASE_URL}/completions")
    request = Net::HTTP::Post.new(uri)
    request["Authorization"] = "Bearer #{@api_key}"
    request["Content-Type"] = "application/json"
    request.body = {
      prompt: "Parse the following credit report document: #{document_content}",
      max_tokens: 1000
    }.to_json

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    if response.code.to_i == 200
      JSON.parse(response.body)
    else
      raise "Error parsing credit report: #{response.message}"
    end
  end
end
