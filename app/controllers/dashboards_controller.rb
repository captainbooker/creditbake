# app/controllers/dashboards_controller.rb
class DashboardsController < ApplicationController
  include ApplicationHelper
  before_action :authenticate_user!

  def index
    @user = current_user
    @credit_report = CreditReport.where(user_id: current_user.id).order(created_at: :desc).first
    @accounts = current_user.accounts
    @inquiries = current_user.inquiries
    @negative_accounts = current_user.accounts.joins(:bureau_details)
                              .where.not(bureau_details: { payment_status: ['As Agreed', 'Current'] })
                              .distinct
    @letters = current_user.letters.includes(
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

  def scores
    if params[:client_id].present?
      credit_report = CreditReport.where(client_id: params[:client_id]).order(created_at: :desc).first
    else
      credit_report = CreditReport.where(user_id: current_user.id).order(created_at: :desc).first
    end
    render json: {
      experian_score: credit_report&.experian_score,
      transunion_score: credit_report&.transunion_score,
      equifax_score: credit_report&.equifax_score
    }
  end

  def disputing
    @inquiries = current_user.inquiries.order(created_at: :desc)
    @accounts = current_user.accounts.includes(:bureau_details).order(created_at: :desc)
    @public_records = current_user.public_records.includes(:bureau_details).order(created_at: :desc)
  end  

  def save_challenges
    # Determine if we are working with a client or a user
    client = Client.find(params[:client_id]) if params[:client_id].present?
    user = current_user unless client.present?
  
    if client
      client.inquiries.update_all(challenge: false)
      client.accounts.update_all(challenge: false)
      client.public_records.update_all(challenge: false)
  
      if params[:inquiry_ids].present?
        selected_inquiries = params[:inquiry_ids].select { |_, v| v == 'true' }.keys
        Inquiry.where(id: selected_inquiries, client_id: client.id).update_all(challenge: true)
      end
  
      if params[:account_ids].present?
        selected_accounts = params[:account_ids].select { |_, v| v == 'true' }.keys
        selected_accounts.each do |account_id|
          Account.where(id: account_id, client_id: client.id).update_all(challenge: true)
        end
      end
  
      if params[:public_record_ids].present?
        selected_public_records = params[:public_record_ids].select { |_, v| v == 'true' }.keys
        selected_public_records.each do |public_record_id|
          PublicRecord.where(id: public_record_id, client_id: client.id).update_all(challenge: true)
        end
      end

      redirect_to letters_client_path(client), notice: 'Challenged items saved successfully.'
    else
      current_user.inquiries.update_all(challenge: false)
      current_user.accounts.update_all(challenge: false)
      current_user.public_records.update_all(challenge: false)
  
      if params[:inquiry_ids].present?
        selected_inquiries = params[:inquiry_ids].select { |_, v| v == 'true' }.keys
        Inquiry.where(id: selected_inquiries, user_id: current_user.id).update_all(challenge: true)
      end
  
      if params[:account_ids].present?
        selected_accounts = params[:account_ids].select { |_, v| v == 'true' }.keys
        selected_accounts.each do |account_id|
          Account.where(id: account_id, user_id: current_user.id).update_all(challenge: true)
        end
      end
  
      if params[:public_record_ids].present?
        selected_public_records = params[:public_record_ids].select { |_, v| v == 'true' }.keys
        selected_public_records.each do |public_record_id|
          PublicRecord.where(id: public_record_id, user_id: current_user.id).update_all(challenge: true)
        end
      end
      redirect_to letters_path, notice: 'Challenged items saved successfully.'
    end
  end
  
  

  def letters
    @letters = current_user.letters
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

  def create_attack
    round = params[:round].to_i
    attack_cost = (round == 11 || round == 12) ? Letter::BANKRUPTCY_LETTERS : Letter::COST
    @resource = params[:client_id].present? ? Client.find(params[:client_id]) : current_user
  
    if @resource.is_a?(Client)
      @path = challenge_client_path(@resource)
      @successful_path = dashboard_client_path(@resource)

      unless ensure_required_documents_for_client(@resource)
        return
      end
    else
      @path = letters_path
      @successful_path = letters_path

      unless ensure_required_documents
        return
      end
    end
  
    if current_user.free_attack > 0 || current_user.credits >= attack_cost
      if @resource.accounts.where(challenge: true).any? || @resource.inquiries.where(challenge: true).any? || @resource.public_records.where(challenge: true).any?
        handle_attack_cost(attack_cost, round)
        create_attack_logic(round, @resource)
        redirect_to @successful_path, notice: 'We are creating your attack letters. They should be done in a few minutes and you will receive an email.'
      else
        redirect_to @path, alert: "Please select items to attack"
      end
    else
      redirect_to maverick_payment_form_url, alert: "You don't have enough credits to generate an attack letter. Please add credits."
    end
  end
  

  def upgrade_plan
    customer_id = params[:customerId]
    card_id = params[:cardId]
    status = params[:status]
    user = User.find_by(maverick_customer_id: customer_id)

    if user && status == 'Success'
      user.update(maverick_card_id: card_id)

      service = MaverickPayments::CustomerCardService.new(user)
      service.fetch_card
      flash[:notice] = 'Plan upgraded successfully!'
    end
  end

  def plan_purchased
    begin
      subscription = Subscription.find(params[:subscription_id])
      service = MaverickPayments::PaymentService.new(current_user, subscription)
  
      if service.process_payment
        subscription_service = MaverickPayments::SubscriptionService.new(current_user, subscription)
        if subscription_service.create_subscription
          new_free_attacks = current_user.free_attacks.to_i + subscription.attacks.to_i
          current_user.update(subscription: subscription, free_attacks: new_free_attacks)
          
          flash[:notice] = "Subscription purchased successfully."
          redirect_to clients_path
        else
          flash[:alert] = "Failed to create subscription. Please try again."
          redirect_to plan_purchased_path
        end
      else
        flash[:alert] = "Payment processing failed. Please try again."
        redirect_to plan_purchased_path
      end
    rescue => e
      Rollbar.error(e)
      flash[:alert] = "An error occurred while processing your subscription. Please try again later."
      redirect_to plan_purchased_path
    end
  end  

  def cancel_subscription
    begin
      subscription = current_user.subscription
      subscription_service = MaverickPayments::SubscriptionService.new(current_user, subscription)
      subscription_service.cancel_subscription_status("Completed")
      flash[:notice] = "Subscription cancelled successfully."
      redirect_to authenticated_root_path
    rescue => e
      Rollbar.error(e, "Failed to cancel subscription", {
        user_id: current_user.id,
        subscription_id: params[:subscription_id]
      })
      flash[:alert] = "An error occurred while cancelling your subscription. Please try again later."
      redirect_to plan_purchased_path
    end
  end

  def resubscribe
    begin
      subscription = Subscription.find(params[:subscription_id])
      subscription_service = MaverickPayments::SubscriptionService.new(current_user, subscription)
      subscription_service.cancel_subscription_status("Completed")
      service = MaverickPayments::PaymentService.new(current_user, subscription)

      if service.process_payment
        subscription_service = MaverickPayments::SubscriptionService.new(current_user, subscription)
        if subscription_service.create_subscription
          current_user.update(subscription: subscription)
          flash[:notice] = "Subscription purchased successfully."
          redirect_to clients_path
        else
          flash[:alert] = "Failed to create subscription. Please try again."
          redirect_to plan_purchased_path
        end
      else
        flash[:alert] = "Payment processing failed. Please try again."
        redirect_to plan_purchased_path
      end

    rescue => e
      Rollbar.error(e)
      flash[:alert] = "An error occurred while processing your subscription. Please try again later."
      redirect_to plan_purchased_path
    end
  end

  private

  def create_attack_logic(round, resource)
    CreateAttackJob.perform_later(resource, round, current_user)
  end

  def handle_attack_cost(attack_cost, round)
    if current_user.free_attack > 0
      current_user.decrement!(:free_attack)
      Spending.create!(user: current_user, amount: 0, description: "Free Letter Generated / #{Date.today.strftime("%B %d, %Y")}")
    else
      current_user.decrement!(:credits, attack_cost)
      Spending.create!(user: current_user, amount: attack_cost, description: "Letter Generated / #{Date.today.strftime("%B %d, %Y")}")
    end
  end
end
