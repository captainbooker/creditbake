OpenAI.configure do |config|
  config.access_token = ENV["OPENAI_ACCESS_KEY"]
  config.organization_id = ENV["OPENAI_ORGANIZATION_ID"]
  config.log_errors = true
end