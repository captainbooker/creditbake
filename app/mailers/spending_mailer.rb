class SpendingMailer < ApplicationMailer
  def mailing_cost_notification(user, mailings)
    @user = user
    @mailings = mailings
    mail(to: @user.email, subject: "You've spent Credits")
  end

  def generate_letter_notification(spending, user)
    @user = user
    @spending = spending

    mail to: @user.email, subject: "You've spent Credits"
end
