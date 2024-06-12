# config/initializers/proxy.rb
require 'net/http'
require 'uri'

if ENV['QUOTAGUARDSTATIC_URL']
  uri = URI.parse(ENV['QUOTAGUARDSTATIC_URL'])
  PROXY_ADDR = uri.host
  PROXY_PORT = uri.port
  PROXY_USER = uri.user
  PROXY_PASS = uri.password
else
  PROXY_ADDR = nil
  PROXY_PORT = nil
  PROXY_USER = nil
  PROXY_PASS = nil
end

def use_quotaguard_proxy(uri)
  if PROXY_ADDR
    Net::HTTP::Proxy(PROXY_ADDR, PROXY_PORT, PROXY_USER, PROXY_PASS).start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
      yield http
    end
  else
    Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
      yield http
    end
  end
end
