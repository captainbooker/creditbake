require 'prawn'
require 'mini_magick'

class DashboardsController < ApplicationController
  include OpenaiPromptable
  before_action :authenticate_user!

  def index
  end

  def disputing
    @inquiries = current_user.inquiries
    @accounts = current_user.accounts.includes(:bureau_details)
  end  

  def save_challenges
    Inquiry.where(id: params[:inquiry_ids], user_id: current_user.id).update_all(challenge: true) if params[:inquiry_ids].present?
    Account.where(id: params[:account_ids], user_id: current_user.id).update_all(challenge: true) if params[:account_ids].present?
    redirect_to letters_path, notice: 'Challenged items saved successfully.'
  end

  def letters
    @letters = current_user.letters
  end

  def create_attack
    # This method will now only be called after successful payment via success callback
    round = params[:round].to_i

    if params[:payment_success] != 'true'
      redirect_to letters_path, alert: 'Payment required.'
      return
    end
    
    create_attack_logic(round)
    redirect_to letters_path, notice: 'Attack created successfully and letters saved.'
  end

  private

  def create_attack_logic(round)
    inquiries = current_user.inquiries.where(challenge: true)
    accounts = current_user.accounts.where(challenge: true)

    inquiry_details = inquiries.map { |inquiry| { name: inquiry.inquiry_name, bureau: inquiry.credit_bureau } }
    account_details = accounts.map { |account| { number: account.account_number, bureau: account.bureau_details.pluck(:bureau) } }

    responses = send_prompts_for_round(round, inquiry_details, account_details)

    letter = Letter.create!(
      name: "Round #{round}",
      experian_document: responses[:experian],
      transunion_document: responses[:transunion],
      equifax_document: responses[:equifax],
      user: current_user
    )

    generate_pdfs(letter)
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
  
  def add_image_to_pdf(image_path, pdf, title)
    pdf.start_new_page
    pdf.text title
    pdf.image image_path, width: 500, height: 400, position: :center
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

  def generate_pdf(letter, document_field, pdf_attachment)
    document_content = letter.send(document_field)
    bureau_name = document_field.split('_').first.capitalize
    user = current_user

    pdf_path = Rails.root.join("tmp/#{bureau_name}_letter_#{letter.id}.pdf")

    Prawn::Document.generate(pdf_path) do |pdf|
      pdf.text document_content

      # Add ID Document (always an image) if attached
      if user.id_document.attached?
        id_document_path = save_attachment_to_temp(user.id_document)
        add_image_to_pdf(id_document_path, pdf, "ID Document:")
      end

      # Add Utility Bill (can be image or PDF) if attached
      if user.utility_bill.attached?
        utility_bill_path = save_attachment_to_temp(user.utility_bill)
        case file_mime_type(utility_bill_path)
        when 'application/pdf'
          image_path = convert_pdf_to_image(utility_bill_path)
          add_image_to_pdf(image_path, pdf, "Utility Bill:")
        when 'image/jpeg', 'image/png'
          add_image_to_pdf(utility_bill_path, pdf, "Utility Bill:")
        else
          Rails.logger.error "Unsupported file type: #{file_mime_type(utility_bill_path)}"
        end
      end
    end

    letter.send(pdf_attachment).attach(io: File.open(pdf_path), filename: "#{bureau_name}_letter_#{letter.id}.pdf", content_type: 'application/pdf')
  end
end
