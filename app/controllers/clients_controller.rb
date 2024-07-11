class ClientsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_client, only: [:edit, :dashboard, :credit_report]

  def index
    @clients = current_user.clients.order(created_at: :desc)
                                    .page(params[:page])
                                    .per(10)
  end

  def show
    @client = current_user.clients.find(params[:id])
  end

  def new
    @client = Client.new
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
    @client = Client.find(params[:id])
  end

  def update
    @client = current_user.clients.find(params[:id])
    if @client.update(client_params)
      redirect_to @client, notice: 'Client was successfully updated.'
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

  private

  def set_client
    @client = Client.find(params[:id])
  end

  def client_params
    params.require(:client).permit(:email, :signature_data, :first_name, :last_name, :phone_number, :street_address, :city, :state, :postal_code, :country, :ssn_last4, :id_document, :utility_bill, :additional_document1, :additional_document2, :free_attack)
  end
end
