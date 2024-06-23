# app/controllers/dashboards_controller.rb
class DashboardsController < ApplicationController
  include ApplicationHelper
  include OpenaiPromptable
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
                                              equifax_pdf_attachment: :blob
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
                             equifax_pdf_attachment: :blob
                           )
                           .order(created_at: :desc)
                           .page(params[:page])
                           .per(10)
  end

  def create_attack
    round = params[:round].to_i
    attack_cost = 24.99

    if current_user.credits < attack_cost
      redirect_to payment_path, alert: "You don't have enough credits to generate an attack letter. Please add credits."
      return
    end

    if current_user.accounts.where(challenge: true).any? || current_user.inquiries.where(challenge: true).any?
      create_attack_logic(round)
      redirect_to letters_path, notice: 'Attack created successfully and letters saved.'
    else
      redirect_to payment_path, alert: "Please select items to attack"
      return
    end
  end

  private

  def create_attack_logic(round)
    inquiries = current_user.inquiries.where(challenge: true)
    accounts = current_user.accounts.where(challenge: true).includes(:bureau_details)
    public_records = current_user.public_records.where(challenge: true).includes(:bureau_details)
    inquiry_details = inquiries.map { |inquiry| { name: inquiry.inquiry_name, bureau: inquiry.credit_bureau } }
    account_details = accounts.map do |account|
      {
        name: account.name,
        number: account.account_number,
        reason: account.reason,
        bureau_details: account.bureau_details.map do |detail|
          {
            bureau: detail.bureau,
            balance_owed: detail.balance_owed,
            high_credit: detail.high_credit,
            credit_limit: detail.credit_limit,
            past_due_amount: detail.past_due_amount,
            payment_status: detail.payment_status,
            date_opened: detail.date_opened,
            date_of_last_payment: detail.date_of_last_payment,
            last_reported: detail.last_reported
          }
        end
      }
    end

    responses = send_prompts_for_round(round, inquiry_details, account_details, public_records)
    phase_info = attack_phase_info(round)
    
    letter = Letter.create!(
      name: phase_info[:title],
      experian_document: responses[:experian],
      transunion_document: responses[:transunion],
      equifax_document: responses[:equifax],
      user: current_user
    )

    generate_pdfs(letter)
    current_user.decrement!(:credits, 24.99)
    spending = Spending.create!(user: current_user, amount: 24.99, description: "Letter Generated: #{letter.id}")
    # SpendingMailer.generate_letter_notification(spending, current_user).deliver_later
  end

  def generate_pdfs(letter)
    generate_pdf(letter, 'experian_document', :experian_pdf)
    generate_pdf(letter, 'transunion_document', :transunion_pdf)
    generate_pdf(letter, 'equifax_document', :equifax_pdf)
  end

  def save_attachment_to_temp(attachment)
    attachment_path = Rails.root.join("tmp/#{attachment.filename}")
    File.open(attachment_path, 'wb') do |file|
      file.write(attachment.download)
    end
    attachment_path
  end

  def add_image_to_pdf(image_path, pdf, title, width, height)
    pdf.start_new_page
    pdf.text title
    pdf.image image_path, width: width, height: height, position: :center
  end

  def convert_pdf_to_image(pdf_path)
    image_path = pdf_path.sub('.pdf', '.png')
    MiniMagick::Tool::Convert.new do |convert|
      convert.density(300)
      convert.quality(200)
      convert << pdf_path << image_path
    end
    image_path
  end

  def file_mime_type(path)
    `file --brief --mime-type #{path}`.strip
  end

  def add_attachments_to_pdf(pdf)
    add_image_to_pdf(current_user.signature, pdf, "Signature:", 100, 100) if current_user.signature.attached?
    add_id_document_to_pdf(pdf) if current_user.id_document.attached?
    add_utility_bill_to_pdf(pdf) if current_user.utility_bill.attached?
    add_additional_document_1(pdf) if current_user.additional_document1.attached?
    add_additional_document_2(pdf) if current_user.additional_document2.attached?
  end

  def add_utility_bill_to_pdf(pdf)
    utility_bill_path = save_attachment_to_temp(current_user.utility_bill)
    case file_mime_type(utility_bill_path)
    when 'application/pdf'
      image_path = convert_pdf_to_image(utility_bill_path)
      add_image_to_pdf(image_path, pdf, "Utility Bill:", 500, 400)
    when 'image/jpeg', 'image/png'
      add_image_to_pdf(utility_bill_path, pdf, "Utility Bill:", 400, 300)
    else
      Rails.logger.error "Unsupported file type: #{file_mime_type(utility_bill_path)}"
    end
  end

  def add_additional_document_1(pdf)
    additional_document1_path = save_attachment_to_temp(current_user.additional_document1)
    case file_mime_type(additional_document1_path)
    when 'application/pdf'
      image_path = convert_pdf_to_image(additional_document1_path)
      add_image_to_pdf(image_path, pdf, "Additional Documents 1:", 500, 400)
    when 'image/jpeg', 'image/png'
      add_image_to_pdf(additional_document1_path, pdf, "Additional Documents 1:", 400, 300)
    else
      Rails.logger.error "Unsupported file type: #{file_mime_type(additional_document1_path)}"
    end
  end

  def add_additional_document_2(pdf)
    additional_document2_path = save_attachment_to_temp(current_user.additional_document2)
    case file_mime_type(additional_document2_path)
    when 'application/pdf'
      image_path = convert_pdf_to_image(additional_document2_path)
      add_image_to_pdf(image_path, pdf, "Additional Documents 2:", 500, 400)
    when 'image/jpeg', 'image/png'
      add_image_to_pdf(additional_document2_path, pdf, "Additional Documents 2:", 400, 300)
    else
      Rails.logger.error "Unsupported file type: #{file_mime_type(additional_document2_path)}"
    end
  end

  def add_id_document_to_pdf(pdf)
    id_document_path = save_attachment_to_temp(current_user.additional_document2)
    case file_mime_type(id_document_path)
    when 'application/pdf'
      image_path = convert_pdf_to_image(id_document_path)
      add_image_to_pdf(image_path, pdf, "ID Document:", 500, 400)
    when 'image/jpeg', 'image/png'
      add_image_to_pdf(id_document_path, pdf, "ID Document:", 400, 300)
    else
      Rails.logger.error "Unsupported file type: #{file_mime_type(id_document_path)}"
    end
  end


  def generate_pdf(letter, document_field, pdf_attachment)
    document_content = letter.send(document_field)
    bureau_name = document_field.split('_').first.capitalize
    user = current_user

    pdf_path = Rails.root.join("tmp/#{bureau_name}_letter_#{letter.id}.pdf")

    Prawn::Document.generate(pdf_path) do |pdf|
      pdf.text document_content

      add_attachments_to_pdf(pdf)
    end

    letter.send(pdf_attachment).attach(io: File.open(pdf_path), filename: "#{bureau_name}_letter_#{letter.id}.pdf", content_type: 'application/pdf')
  end
end
