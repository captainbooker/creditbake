# app/mailers/contact_mailer.rb
class ContactMailer < ApplicationMailer
  def send_contact_email
    @contact_form = params[:contact_form]
    mail(
      to: 'support@creditbake.com',
      subject: 'New Contact Form Submission'
    )
  end
end
