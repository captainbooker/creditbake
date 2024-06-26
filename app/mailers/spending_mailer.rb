class SpendingMailer < ApplicationMailer
  def mailing_cost_notification(user, mailings)
    @user = user
    @mailings = mailings
    mail(to: @user.email, subject: "You've spent Credits")
  end

  def notify_admin_user(current_user, mailing, mailings)
    @user = current_user
    @mailing = mailing
    @mailings = mailings
    mail(to: "support@creditbake.com", subject: "NEW MAILING REQUEST")
  end

  def generate_letter_notification(spending, user)
    @user = user
    @spending = spending

    mail to: @user.email, subject: "You've spent Credits"
  end
end
