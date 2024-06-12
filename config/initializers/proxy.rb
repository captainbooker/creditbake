require 'uri'

if ENV["QUOTAGUARDSTATIC_URL"]
  uri = URI.parse(ENV["QUOTAGUARDSTATIC_URL"])
  proxy_class = Net::HTTP::Proxy(uri.host, uri.port, uri.user, uri.password)

  Net::HTTP.class_eval do
    @proxy_class = proxy_class

    def self.new(*args, &block)
      @proxy_class.new(*args, &block)
    end
  end
end
