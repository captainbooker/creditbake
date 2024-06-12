# app/models/contact_form.rb
class ContactForm
  include ActiveModel::Model

  attr_accessor :full_name, :email, :phone, :message

  validates :full_name, :email, :message, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
end
