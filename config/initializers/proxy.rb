# config/initializers/proxy.rb
require 'net/http'
require 'uri'

if ENV['QUOTAGUARDSTATIC_URL']
  uri = URI.parse(ENV['QUOTAGUARDSTATIC_URL'])
  proxy_class = Net::HTTP::Proxy(uri.host, uri.port, uri.user, uri.password)

  Net::HTTP.class_eval do
    @proxy_class = proxy_class

    def self.new(*args, &block)
      if @proxy_class
        @proxy_class.new(*args, &block)
      else
        super
      end
    end
  end
end
