require 'net/http'
require 'uri'

# You don't need to redefine Net::HTTP globally. Instead, configure the proxy per request.
def use_quotaguard_proxy(uri)
  if ENV['QUOTAGUARDSTATIC_URL']
    proxy_uri = URI.parse(ENV['QUOTAGUARDSTATIC_URL'])
    Net::HTTP::Proxy(proxy_uri.host, proxy_uri.port, proxy_uri.user, proxy_uri.password).start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
      yield http
    end
  else
    Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
      yield http
    end
  end