class ApplicationMailer < ActionMailer::Base
  require 'sendgrid-ruby'
  include SendGrid

  default from: 'support@creditbake.com'
  layout 'mailer'
end
