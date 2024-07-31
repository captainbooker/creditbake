class ClientsController < ApplicationController
  before_action :authenticate_user!, except: [:new_with_token, :create_with_token]
  before_action :set_client, only: [:edit, :dashboard, :credit_report, :challenge, :letters, :edit]

  layout :determine_layout

  def index
    @clients = current_user.clients.order(created_at: :desc)
                                    .page(params[:page])
                                    .per(10)
  end

  def show
    @client = current_user.clients.find(params[:id])
  end

  def new
    @new_client = Client.new
  end

  def create
    @client = current_user.clients.build(client_params)
    if @client.save
      redirect_to @client, notice: 'Client was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    @client = current_user.clients.find(params[:id])
    if @client.update(client_params)
      redirect_to dashboard_client_path, notice: 'Client was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @client = current_user.clients.find(params[:id])
    @client.destroy
    redirect_to clients_url, notice: 'Client was successfully destroyed.'
  end

  def dashboard
    @user = current_user
    @credit_report = CreditReport.where(client_id: @client.id).order(created_at: :desc).first
    @accounts = @client.accounts
    @inquiries = @client.inquiries
    @negative_accounts = @client.accounts.joins(:bureau_details)
                              .where.not(bureau_details: { payment_status: ['As Agreed', 'Current'] })
                              .distinct
    @letters = @client.letters.includes(
                                          creditor_dispute_attachment: :blob,
                                          experian_pdf_attachment: :blob,
                                          transunion_pdf_attachment: :blob,
                                          equifax_pdf_attachment: :blob,
                                          bankruptcy_pdf_attachment: :blob
                                        )
                                        .order(created_at: :desc)
                                        .page(params[:page])
                                        .per(10)
  end

  def credit_report
    @credit_reports = @client.credit_reports
  end

  def challenge
    @inquiries = @client.inquiries.order(created_at: :desc)
    @accounts = @client.accounts.includes(:bureau_details).order(created_at: :desc)
    @public_records = @client.public_records.includes(:bureau_details).order(created_at: :desc)
  end

  def letters
    @letters = @client.letters
                           .includes(
                             creditor_dispute_attachment: :blob,
                             experian_pdf_attachment: :blob,
                             transunion_pdf_attachment: :blob,
                             equifax_pdf_attachment: :blob,
                             bankruptcy_pdf_attachment: :blob
                           )
                           .order(created_at: :desc)
                           .page(params[:page])
                           .per(10)
  end

  def send_invite
    invite = current_user.client_invites.create!(email: params[:email], expires_at: 2.days.from_now)
    ClientMailer.with(invite: invite).send_invite_email.deliver_now
    redirect_to clients_path, notice: 'Invite link has been sent to the client.'
  end

  def new_with_token
    @invite = ClientInvite.find_by(token: params[:token])
    @user = @invite.user

    if @invite && @invite.expires_at > Time.current
      @client = Client.new
      @token_valid = true
      render :new_with_token
    else
      redirect_to root_path, alert: 'The invite link has expired or is invalid.'
    end
  end

  def create_with_token
    @invite = ClientInvite.find_by(token: params[:client][:token])

    if @invite && @invite.expires_at > Time.current
      @client = @invite.user.clients.build(client_params)

      if @client.save
        @invite.destroy
        redirect_to @client, notice: 'Client was successfully created.'
      else
        render :new_with_token
      end
    else
      redirect_to root_path, alert: 'The invite link has expired or is invalid.'
    end
  end

  private

  def set_client
    @client = current_user.clients.find_by(id: params[:id])
    unless @client
      redirect_to clients_path, alert: "You don't have access to this client."
    end
  end
  

  def client_params
    params.require(:client).permit(:email, :signature_data, :first_name, :last_name, :phone_number, :street_address, :city, :state, :postal_code, :country, :ssn_last4, :id_document, :utility_bill, :additional_document1, :additional_document2, :free_attack, :signature)
  end

  def determine_layout
    action_name == 'new_with_token' ? 'invitation' : 'authenticated'
  end
end
