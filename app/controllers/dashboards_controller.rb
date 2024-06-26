# app/controllers/dashboards_controller.rb
class DashboardsController < ApplicationController
  include ApplicationHelper
  before_action :authenticate_user!
  before_action :ensure_required_documents, only: [:create_attack]

  def index
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
    credit_report = CreditReport.where(user_id: current_user.id).order(created_at: :desc).first
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
    # Reset all challenges for the current user
    current_user.inquiries.update_all(challenge: false)
    current_user.accounts.update_all(challenge: false)
  
    # Set challenge for selected inquiries
    if params[:inquiry_ids].present?
      selected_inquiries = params[:inquiry_ids].select { |_, v| v == 'true' }.keys
      Inquiry.where(id: selected_inquiries, user_id: current_user.id).update_all(challenge: true)
    end
  
    # Set challenge for selected accounts
    if params[:account_ids].present?
      selected_accounts = params[:account_ids].select { |_, v| v == 'true' }.keys
      selected_accounts.each do |account_id|
        reason = params[:account_reasons][account_id]
        Account.where(id: account_id, user_id: current_user.id).update_all(challenge: true, reason: reason)
      end
    end

    if params[:public_record_ids].present?
      selected_public_records = params[:public_record_ids].select { |_, v| v == 'true' }.keys
      selected_public_records.each do |public_record_id|
        reason = params[:public_record_reasons][public_record_id]
        PublicRecord.where(id: public_record_id, user_id: current_user.id).update_all(challenge: true, reason: reason)
      end
    end
  
    redirect_to letters_path, notice: 'Challenged items saved successfully.'
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
  
    if current_user.free_attack > 0 || current_user.credits >= attack_cost
      if current_user.accounts.where(challenge: true).any? || current_user.inquiries.where(challenge: true).any? || current_user.public_records.where(challenge: true).any?
        handle_attack_cost(attack_cost, round)
        create_attack_logic(round)
        redirect_to letters_path, notice: 'We are creating your attack letters. They should be done in a few minutes and you will receive an email.'
      else
        redirect_to payment_path, alert: "Please select items to attack"
        return
      end
    else
      redirect_to maverick_payment_form_url, alert: "You don't have enough credits to generate an attack letter. Please add credits."
    end
  end

  private

  def create_attack_logic(round)
    CreateAttackJob.perform_later(current_user, round)
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
