class UserMailer < ApplicationMailer

  def welcome_email(user)
    @user = user
    mail(to: @user.email, subject: 'Welcome to My Awesome Site')
  end

  def notification_email(user, message)
    @user = user
    @message = message
    mail(to: @user.email, subject: 'Notification from CreditBake')
  end
end
