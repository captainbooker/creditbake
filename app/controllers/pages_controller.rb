class PagesController < ApplicationController
  def landing
    @contact_form = ContactForm.new
  end

  def dashboard
  end

  def privacy_policy
  end

  def terms_and_conditions
  end

  def sitemap
  end

  def pricing
  end

  def suppprt
    @contact_form = ContactForm.new
  end
end