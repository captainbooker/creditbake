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

    public_record_details = public_records.map do |record|
      {
        name: record.public_record_type,
        number: record.reference_number,
        reason: record.reason,
        bureau_details: record.bureau_details.map do |detail|
          {
            bureau: detail.bureau,
            status: detail.status,
            date_filed_reported: detail.date_filed_reported,
            closing_date: detail.closing_date,
            asset_amount: detail.asset_amount,
            court: detail.court,
            liability: detail.liability,
            exempt_amount: detail.exempt_amount
          }
        end
      }
    end

    openai = OpenaiPromptableService.new(user)
    responses = openai.send_prompts_for_round(round, inquiry_details, account_details, public_record_details)
    phase_info = attack_phase_info(round)
    
    letter_attributes = {
      name: phase_info[:title],
      user: user
    }
    letter_attributes[:experian_document] = responses[:experian] if responses[:experian]
    letter_attributes[:transunion_document] = responses[:transunion] if responses[:transunion]
    letter_attributes[:equifax_document] = responses[:equifax] if responses[:equifax]
    letter_attributes[:bankruptcy_document] = responses[:bankruptcy] if responses[:bankruptcy]

    letter = Letter.create!(letter_attributes)

    generate_pdfs(letter, user)
    UserMailer.notification_email(user, "Letters have been successfully generated, login to view them.").deliver_later
  end

  private

  def generate_pdfs(letter, user)
    generate_pdf(letter, 'experian_document', :experian_pdf, user) if letter.experian_document.present?
    generate_pdf(letter, 'transunion_document', :transunion_pdf, user) if letter.transunion_document.present?
    generate_pdf(letter, 'equifax_document', :equifax_pdf, user) if letter.equifax_document.present?
    generate_pdf(letter, 'bankruptcy_document', :bankruptcy_pdf, user) if letter.bankruptcy_document.present?
  end

  def save_attachment_to_temp(attachment)
    tmp_dir = Rails.root.join('tmp')
    Dir.mkdir(tmp_dir) unless Dir.exist?(tmp_dir)
  
    unique_filename = "#{SecureRandom.hex}_#{attachment.filename}"
    attachment_path = tmp_dir.join(unique_filename)
  
    begin
      File.open(attachment_path, 'wb') do |file|
        file.write(attachment.download)
      end
      Rails.logger.info "Saved attachment to #{attachment_path}"
    rescue => e
      Rollbar.error("Failed to save attachment to temp file: #{e.message}")
      raise
    end
  
    attachment_path
  end

  def file_mime_type(path)
    `file --brief --mime-type #{path}`.strip
  end

  def convert_to_supported_image_type(image_path)
    supported_types = %w[image/jpeg image/png image/jpg]
    return image_path if supported_types.include?(file_mime_type(image_path))

    new_image_path = image_path.sub(File.extname(image_path), '.png')
    MiniMagick::Tool::Convert.new do |convert|
      convert << image_path << new_image_path
    end

    new_image_path
  end

  def add_attachments_to_pdf(main_pdf_path, user)
    add_signature_to_pdf(main_pdf_path, user) if user.signature.attached?
    add_id_document_to_pdf(main_pdf_path, user) if user.id_document.attached?
    add_utility_bill_to_pdf(main_pdf_path, user) if user.utility_bill.attached?
    add_additional_document_1(main_pdf_path, user) if user.additional_document1.attached?
    add_additional_document_2(main_pdf_path, user) if user.additional_document2.attached?
  end

  def add_signature_to_pdf(main_pdf_path, user)
    signature_path = save_attachment_to_temp(user.signature)
    unless File.exist?(signature_path)
      Rollbar.error "Attachment file not found: #{signature_path}"
      raise ArgumentError, "Attachment file not found: #{signature_path}"
    end

    case file_mime_type(signature_path)
    when 'application/pdf'
      merge_pdfs(main_pdf_path, signature_path)
    when 'image/jpeg', 'image/png', 'image/jpg'
      signature_path = convert_to_supported_image_type(signature_path)
      add_image_to_pdf(signature_path, main_pdf_path, "Signature:", width: 175, height: 175)
    else
      Rollbar.error("Unsupported file type: #{file_mime_type(signature_path)}")
    end
  end

  def add_utility_bill_to_pdf(main_pdf_path, user)
    utility_bill_path = save_attachment_to_temp(user.utility_bill)
    unless File.exist?(utility_bill_path)
      Rollbar.error "Attachment file not found: #{utility_bill_path}"
      raise ArgumentError, "Attachment file not found: #{utility_bill_path}"
    end

    case file_mime_type(utility_bill_path)
    when 'application/pdf'
      merge_pdfs(main_pdf_path, utility_bill_path)
    when 'image/jpeg', 'image/png', 'image/jpg'
      utility_bill_path = convert_to_supported_image_type(utility_bill_path)
      add_image_to_pdf(utility_bill_path, main_pdf_path, "Utility Bill:")
    else
      Rollbar.error("Unsupported file type: #{file_mime_type(utility_bill_path)}")
    end
  end

  def add_additional_document_1(main_pdf_path, user)
    additional_document1_path = save_attachment_to_temp(user.additional_document1)
    unless File.exist?(additional_document1_path)
      Rollbar.error "Attachment file not found: #{additional_document1_path}"
      raise ArgumentError, "Attachment file not found: #{additional_document1_path}"
    end

    case file_mime_type(additional_document1_path)
    when 'application/pdf'
      merge_pdfs(main_pdf_path, additional_document1_path)
    when 'image/jpeg', 'image/png', 'image/jpg'
      additional_document1_path = convert_to_supported_image_type(additional_document1_path)
      add_image_to_pdf(additional_document1_path, main_pdf_path, "Additional Documents 1:")
    else
      Rollbar.error("Unsupported file type: #{file_mime_type(additional_document1_path)}")
    end
  end

  def add_additional_document_2(main_pdf_path, user)
    additional_document2_path = save_attachment_to_temp(user.additional_document2)
    unless File.exist?(additional_document2_path)
      Rollbar.error "Attachment file not found: #{additional_document2_path}"
      raise ArgumentError, "Attachment file not found: #{additional_document2_path}"
    end

    case file_mime_type(additional_document2_path)
    when 'application/pdf'
      merge_pdfs(main_pdf_path, additional_document2_path)
    when 'image/jpeg', 'image/png', 'image/jpg'
      additional_document2_path = convert_to_supported_image_type(additional_document2_path)
      add_image_to_pdf(additional_document2_path, main_pdf_path, "Additional Documents 2:")
    else
      Rollbar.error("Unsupported file type: #{file_mime_type(additional_document2_path)}")
    end
  end

  def add_id_document_to_pdf(main_pdf_path, user)
    id_document_path = save_attachment_to_temp(user.id_document)
    unless File.exist?(id_document_path)
      Rollbar.error "Attachment file not found: #{id_document_path}"
      raise ArgumentError, "Attachment file not found: #{id_document_path}"
    end

    case file_mime_type(id_document_path)
    when 'application/pdf'
      merge_pdfs(main_pdf_path, id_document_path)
    when 'image/jpeg', 'image/png', 'image/jpg'
      id_document_path = convert_to_supported_image_type(id_document_path)
      add_image_to_pdf(id_document_path, main_pdf_path, "ID Document:")
    else
      Rollbar.error("Unsupported file type: #{file_mime_type(id_document_path)}")
    end
  end

  def merge_pdfs(main_pdf_path, additional_pdf_path)
    combined_pdf = CombinePDF.new
    combined_pdf << CombinePDF.load(main_pdf_path)
    combined_pdf << CombinePDF.load(additional_pdf_path)
    combined_pdf.save main_pdf_path
  end

  def add_image_to_pdf(image_path, pdf_path, title, width: 500, height: 400)
    pdf_with_image_path = pdf_path.sub('.pdf', '_with_image.pdf')
    Prawn::Document.generate(pdf_with_image_path) do |pdf|
      pdf.start_new_page
      pdf.text title
      pdf.image image_path, width: width, height: height, position: :center
    end
    merge_pdfs(pdf_path, pdf_with_image_path)
  end

  def generate_pdf(letter, document_field, pdf_attachment, user)
    document_content = letter.send(document_field)
    bureau_name = document_field.split('_').first.capitalize
    tmp_dir = Rails.root.join('tmp')
    Dir.mkdir(tmp_dir) unless Dir.exist?(tmp_dir)
    pdf_path = tmp_dir.join("#{bureau_name}_letter_#{letter.id}_#{SecureRandom.hex}.pdf")

    Prawn::Document.generate(pdf_path) do |pdf|
      pdf.text document_content
      pdf.move_down 10
      pdf.text "SSN Last 4 Digits: #{user.ssn_last4}", size: 14, style: :bold
    end

    add_attachments_to_pdf(pdf_path, user)

    letter.send(pdf_attachment).attach(io: File.open(pdf_path), filename: "#{bureau_name}_letter_#{letter.id}.pdf", content_type: 'application/pdf')
    File.delete(pdf_path) if File.exist?(pdf_path)
  end
end
