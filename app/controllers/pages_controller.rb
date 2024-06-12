class PagesController < ApplicationController
  def landing
    @contact_form = ContactForm.new
  end

  def dashboard
  end
end