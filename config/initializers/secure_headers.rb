# config/initializers/secure_headers.rb
SecureHeaders::Configuration.default do |config|
  config.csp = {
    default_src: ["'self'"],
    script_src: ["'self'", "'unsafe-inline'", "'unsafe-eval'", "https:"],
    style_src: ["'self'", "'unsafe-inline'", "https:"],
    img_src: ["'self'", "data:", "https:"],
    font_src: ["'self'", "https:", "data:"],
    connect_src: ["'self'", "https:", "wss:"],
    media_src: ["'self'", "https:"],
    object_src: ["'none'"],
    frame_src: ["'self'", "https:"],
    child_src: ["'self'"],
    form_action: ["'self'"],
    frame_ancestors: ["'none'"],
    base_uri: ["'self'"],
    plugin_types: ["application/pdf"]
  }

  config.hsts = "max-age=#{1.year.to_i}; includeSubdomains; preload"
  config.x_frame_options = 'DENY'
  config.x_content_type_options = 'nosniff'
  config.x_xss_protection = '1; mode=block'
  config.x_download_options = 'noopen'
  config.x_permitted_cross_domain_policies = 'none'
  config.referrer_policy = 'strict-origin-when-cross-origin'
end
