class PagesController < ApplicationController
  def landing
    @contact_form = ContactForm.new
  end

  def dashboard
  end

  def privacy_policy
  end

  def terms_of_use
  end

  def sitemap
  end
end