class ClientMailer < ApplicationMailer
  def send_invite_email
    @invite = params[:invite]
    @user = @invite.user
    @url = new_with_token_clients_url(token: @invite.token)
    mail(to: @invite.email, subject: 'Create Your Profile')
  end
end
