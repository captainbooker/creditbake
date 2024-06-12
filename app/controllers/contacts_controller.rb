class ContactsController < ApplicationController
  def new
    @contact_form = ContactForm.new
  end

  def create
    @contact_form = ContactForm.new(contact_form_params)

    if @contact_form.valid?
      ContactMailer.with(contact_form: @contact_form).send_contact_email.deliver_now
      redirect_to new_contact_path, notice: 'Your message has been sent!'
    else
      render :new
    end
  end

  private

  def contact_form_params
    params.require(:contact_form).permit(:full_name, :email, :phone, :message)
  end
end
