class ApplicationMailer < ActionMailer::Base
  require 'sendgrid-ruby'
  include SendGrid

  default from: "CreditBake <support@creditbake.com>"
  layout 'mailer'
end
