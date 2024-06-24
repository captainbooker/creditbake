class CreateAttackJob < ApplicationJob
  queue_as :default
  include ApplicationHelper

  def perform(user, round)
    inquiries = user.inquiries.where(challenge: true)
    accounts = user.accounts.where(challenge: true).includes(:bureau_details)
    public_records = user.public_records.where(challenge: true).includes(:bureau_details)
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

    openai = OpenaiPromptableService.new(user)
    responses = openai.send_prompts_for_round(round, inquiry_details, account_details, public_records)
    phase_info = attack_phase_info(round)
    
    letter = Letter.create!(
      name: phase_info[:title],
      experian_document: responses[:experian],
      transunion_document: responses[:transunion],
      equifax_document: responses[:equifax],
      user: user
    )

    generate_pdfs(letter, user)
    handle_attack_cost(letter, user)
    UserMailer.notification_email(user, "Letters have been sucessfully generated, login to view them.").deliver_later
  end

  private

  def handle_attack_cost(letter, user)
    if user.free_attack > 0
      user.decrement!(:free_attack)
      Spending.create!(user: user, amount: 0, description: "Free Letter Generated: #{letter.id}")
    else
      user.decrement!(:credits, Letter::COST)
      Spending.create!(user: user, amount: Letter::COST, description: "Letter Generated: #{letter.id}")
    end
  end

  def generate_pdfs(letter, user)
    generate_pdf(letter, 'experian_document', :experian_pdf, user)
    generate_pdf(letter, 'transunion_document', :transunion_pdf, user)
    generate_pdf(letter, 'equifax_document', :equifax_pdf, user)
  end

  def save_attachment_to_temp(attachment)
    tmp_dir = Rails.root.join('tmp')
    Dir.mkdir(tmp_dir) unless Dir.exist?(tmp_dir) # Ensure tmp directory exists
  
    # Ensure the filename is unique
    unique_filename = "#{SecureRandom.hex}_#{attachment.filename}"
    attachment_path = tmp_dir.join(unique_filename)
  
    begin
      File.open(attachment_path, 'wb') do |file|
        file.write(attachment.download)
      end
    rescue => e
      Rails.logger.error "Failed to save attachment to temp file: #{e.message}"
      raise
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

  def add_attachments_to_pdf(pdf, user)
    add_image_to_pdf(user.signature, pdf, "Signature:", 100, 100) if user.signature.attached?
    add_id_document_to_pdf(pdf, user) if user.id_document.attached?
    add_utility_bill_to_pdf(pdf, user) if user.utility_bill.attached?
    add_additional_document_1(pdf, user) if user.additional_document1.attached?
    add_additional_document_2(pdf, user) if user.additional_document2.attached?
  end

  def add_utility_bill_to_pdf(pdf, user)
    utility_bill_path = save_attachment_to_temp(user.utility_bill)
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

  def add_additional_document_1(pdf, user)
    additional_document1_path = save_attachment_to_temp(user.additional_document1)
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

  def add_additional_document_2(pdf, user)
    additional_document2_path = save_attachment_to_temp(user.additional_document2)
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

  def add_id_document_to_pdf(pdf, user)
    id_document_path = save_attachment_to_temp(user.id_document)
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


  def generate_pdf(letter, document_field, pdf_attachment, user)
    document_content = letter.send(document_field)
    bureau_name = document_field.split('_').first.capitalize
    user = user
  
    # Ensure tmp directory exists
    tmp_dir = Rails.root.join('tmp')
    Dir.mkdir(tmp_dir) unless Dir.exist?(tmp_dir)
  
    # Generate a unique file path to avoid conflicts
    pdf_path = tmp_dir.join("#{bureau_name}_letter_#{letter.id}_#{SecureRandom.hex}.pdf")
  
    Prawn::Document.generate(pdf_path) do |pdf|
      pdf.text document_content
  
      add_attachments_to_pdf(pdf, user)
    end
  
    letter.send(pdf_attachment).attach(io: File.open(pdf_path), filename: "#{bureau_name}_letter_#{letter.id}.pdf", content_type: 'application/pdf')
  
    # Optionally delete the file after attaching
    File.delete(pdf_path) if File.exist?(pdf_path)
  end
end
