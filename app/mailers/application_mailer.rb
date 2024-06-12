class ApplicationMailer < ActionMailer::Base
  require 'sendgrid-ruby'
  include SendGrid

  default from: 'darren@creditbake.com'
  layout 'mailer'
end
