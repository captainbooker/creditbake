class CreditReportMailer < ApplicationMailer
  def reimport(user)
    @user = user
    mail(to: @user.email, subject: "It's time re-import your credit report")
  end
end
