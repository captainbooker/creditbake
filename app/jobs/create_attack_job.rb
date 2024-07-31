class CreateAttackJob < ApplicationJob
  queue_as :default
  include ApplicationHelper

  def perform(resource, round, current_user)
    inquiries = resource.inquiries.where(challenge: true)
    accounts = resource.accounts.where(challenge: true).includes(:bureau_details)
    public_records = resource.public_records.where(challenge: true).includes(:bureau_details)

    inquiry_details = inquiries.map { |inquiry| { name: inquiry.inquiry_name, bureau: inquiry.credit_bureau, inquiry_date: inquiry.inquiry_date } }
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

    personal_information_details = resource.personal_informations

    openai = OpenaiPromptableService.new(resource)
    responses = openai.send_prompts_for_round(round, inquiry_details, account_details, public_record_details)
    phase_info = attack_phase_info(round)
    
    if resource.is_a?(Client)
      letter_attributes = {
        name: phase_info[:title],
        client: resource
      }
    else
      letter_attributes = {
        name: phase_info[:title],
        user: resource
      }
    end

    letter_attributes[:experian_document] = responses[:experian] if responses[:experian]
    letter_attributes[:transunion_document] = responses[:transunion] if responses[:transunion]
    letter_attributes[:equifax_document] = responses[:equifax] if responses[:equifax]
    letter_attributes[:bankruptcy_document] = responses[:bankruptcy] if responses[:bankruptcy]

    letter = Letter.create!(letter_attributes)

    generate_pdfs(letter, resource, inquiry_details, account_details, personal_information_details, public_records)
    UserMailer.notification_email(current_user, "Letters have been successfully generated, login to view them.").deliver_later
    SpendingMailer.with(user: current_user).send_review.deliver_later(wait: 48.hours)
    CreditReportMailer.reimport(current_user).deliver_later(wait_until: 32.days.from_now)
  end

  private

  def generate_pdfs(letter, user, inquiry_details, account_details, personal_information_details, public_records)
    generate_pdf(letter, 'experian_document', :experian_pdf, user, inquiry_details, account_details, personal_information_details, public_records) if letter.experian_document.present?
    generate_pdf(letter, 'transunion_document', :transunion_pdf, user, inquiry_details, account_details, personal_information_details, public_records) if letter.transunion_document.present?
    generate_pdf(letter, 'equifax_document', :equifax_pdf, user, inquiry_details, account_details, personal_information_details, public_records) if letter.equifax_document.present?
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
      pdf.start_new_page if pdf.cursor < height + 50
      pdf.text title
      pdf.image image_path, width: width, height: height, position: :center
    end
    merge_pdfs(pdf_path, pdf_with_image_path)
    File.delete(pdf_with_image_path) if File.exist?(pdf_with_image_path)
  end
  
  def generate_pdf(letter, document_field, pdf_attachment, user, inquiry_details, account_details, personal_information_details, public_records)
    document_content = letter.send(document_field)
    bureau_name = document_field.split('_').first.capitalize
    tmp_dir = Rails.root.join('tmp')
    Dir.mkdir(tmp_dir) unless Dir.exist?(tmp_dir)
    pdf_path = tmp_dir.join("#{bureau_name}_letter_#{letter.id}_#{SecureRandom.hex}.pdf")
    font_path = Rails.root.join('app', 'assets', 'fonts', 'DejaVuSans.ttf')
    font_bold_path = Rails.root.join('app', 'assets', 'fonts', 'DejaVuSans-Bold.ttf')
  
    bureau_colors = {
      "experian" => "C1D4FF",
      "transunion" => "C1FFD7",
      "equifax" => "FFDDC1"
    }
  
    bureau_mapping = {
      "T" => "transunion",
      "F" => "equifax",
      "X" => "experian"
    }
  
    compliance_codes = ["M", "E", "I", "N", "Q", "D"]
  
    Prawn::Document.generate(pdf_path) do |pdf|
      pdf.font_families.update("DejaVuSans" => { normal: font_path, bold: font_bold_path })
      pdf.font "DejaVuSans"
      if letter.name.in?(["Bankruptcy Step 1", "Bankruptcy Step 2"])
        pdf.text document_content, size: 10
        pdf.move_down 10
        pdf.text "SSN Last 4 Digits: #{user.ssn_last4}", size: 10
        pdf.move_down 20
      else
        pdf.text "From:", size: 10
        pdf.text "#{user.first_name} #{user.last_name}", size: 10
        pdf.text "#{user.street_address}", size: 10
        pdf.text "#{user.city}, #{user.state} #{user.postal_code}", size: 10
        pdf.text "#{user.country}", size: 10
        pdf.text "#{user.phone_number}", size: 10
        pdf.move_down 10
        pdf.text "SSN Last 4 Digits: #{user.ssn_last4}", size: 10
        pdf.move_down 20
    
        pdf.text "To:", size: 10
        pdf.text bureau_company(bureau_name), size: 10
        pdf.text bureau_address(bureau_name), size: 10
        pdf.move_down 20
    
        pdf.text document_content, size: 10
        pdf.move_down 20
    
    
        if personal_information_details.any? { |detail| detail[:bureau].casecmp(bureau_name).zero? }
          pdf.text "Personal Information:", size: 10
        
          fields = [
            { name: "name", display: "Name <color rgb='ff0000'>* BSCF30-31</color>", example: "Darren Booker" },
            { name: "date_of_birth", display: "Date of Birth <color rgb='ff0000'>* BSCF35</color>", example: "1969" },
            { name: "current_addresses", display: "Current Address <color rgb='ff0000'>* BSCF40,42-44</color>", example: "128 Main Street, North Las Vegas, NV 89081" },
            { name: "previous_addresses", display: "Previous Addresses <color rgb='ff0000'>* BSCF40,42-44</color>", example: "" },
            { name: "employers", display: "Employers <color rgb='ff0000'>* BSCF40,42-44</color>", example: "Southern Glazer" }
          ]
        
          fields.each do |field|
            pdf.text "<u><b># Delete Immediately any Unjust and Harmful Elements of Your Report:</b></u>", inline_format: true, size: 10
            pdf.text "#{field[:display]}", size: 10, inline_format: true
        
            # Find the information for the specified bureau
            bureau_info = personal_information_details.find { |pi| pi.bureau.casecmp(bureau_name).zero? && pi.send(field[:name]).present? }&.send(field[:name]) || ""
        
            table_data = [
              ["Bureau", bureau_name.capitalize],
              [
                field[:display],
                "#{bureau_info} <color rgb='ff0000'>#{compliance_codes.sample}</color>"
              ]
            ]
        
            pdf.table(table_data, header: true, row_colors: ['F0F0F0', 'FFFFFF'], cell_style: { inline_format: true, size: 10 })
            pdf.move_down 10
        
            text_content = "REMOVE the display reported #{field[:display].split(' ').first.upcase}(s) of #{bureau_info}. I DO NOT AUTHORIZE you to retain nor report any not proven true correct valid and required reported personal identifier information that is not in exact agreement with my submitted FACTUALLY CORRECT CURRENT PERSONAL IDENTIFIERS as indicated."
        
            box_height = pdf.height_of(text_content, size: 10, width: pdf.bounds.width)
            padding = 10
            box_height += padding
        
            if pdf.cursor < box_height
              pdf.start_new_page
            end
        
            pdf.fill_color "E7DF5E"
            pdf.fill_rectangle [0, pdf.cursor], pdf.bounds.width, box_height
            pdf.fill_color "000000"
            pdf.move_down padding
        
            pdf.text_box text_content,
                         size: 10,
                         at: [0, pdf.cursor],
                         width: pdf.bounds.width,
                         height: box_height,
                         overflow: :shrink_to_fit
        
            pdf.fill_color "000000"
            pdf.move_down box_height - padding
            pdf.move_down 10
          end
        end              
    
        if inquiry_details.any? { |inquiry| inquiry[:bureau].casecmp(bureau_name).zero? }
          pdf.text "Inquiries:", size: 14
          
          filtered_inquiries = inquiry_details.select { |inquiry| inquiry[:bureau].casecmp(bureau_name).zero? }

          filtered_inquiries.each_with_index do |inquiry, index|
            count = index + 1
            pdf.text "<u><b> ##{count}) REMOVE FROM REPORTING NOW ANY OF THE INJURIOUS ASPECTS OF ALLEGATIONS for any item BELOW NOTED:</b></u>", inline_format: true, size: 10
            bureau_key = bureau_mapping.key(inquiry[:bureau].downcase)
            pdf.move_down 5
            pdf.text "<color rgb='ff0000'>*HRCF12</color> #{inquiry[:name]}  |   <color rgb='ff0000'>*HRCF8</color> #{inquiry[:inquiry_date]}</color>  | <color rgb='ff0000'>^^HRCF5-</color> #{inquiry[:bureau]}", inline_format: true, size: 10
            pdf.move_down 4
            pdf.text "#{inquiry[:name]} hypothetic on #{inquiry[:inquiry_date]} necessary adequate and urgent achieved lawful Permissible Purpose, and or is not testimonial obedient as it is currently reported. Please REMOVE from reporting immediately!", size: 10
            pdf.text "------------------------------------------------------------------------------------------------------"
            pdf.move_down 20
          end
        end

        pdf.text "During the investigation period, it is imperative that the reporting entity and any involved repositories ensure the prompt removal of any inaccurately reported items from my credit report. Reporting such items prior to validating the debt constitutes collection activity. Alternatively, these entities may choose to modify their reports to comply with legal requirements and established reporting standards, ensuring maximum accuracy and completeness of the claims made. Additionally, I request the names, addresses, and telephone numbers of individuals contacted during your investigation.", inline_format: true, styles: :underline, size: 10
        pdf.move_down 5
        pdf.text "According to federal guidelines and applicable state mandates, no entity can report damaging information if it lacks ethicalness, truth, fairness, accuracy, completeness, timeliness, verifiability, validity, or compliance with reporting mandates. Upon reviewing my credit report, I have significant concerns regarding the Historical Payment Profile, which appears to deviate from industry standards and potentially disregards regulatory reporting requirements as outlined by the Fair Credit Reporting Act, the Fair Credit Billing Act of 1975, the Equal Credit Opportunity Act, and applicable state mandates. It also seems inconsistent with the Metro 2 Format Reporting Procedures. Such deviations from lawful reporting practices raise the possibility of reporting mistaken or deficient credit data unfairly against me. Referring to FCRA-tort law precedents, such as Fields v. Wilber Law Office, Donald L. Wilber and Kenneth Wilber (USCA-02-C-0072, Seventh Circuit Court, Sept. 2004), I formally request that you either remove the erroneous information or modify it to ensure it is accurately, fairly, and verifiably reported. Furthermore, I demand all documentary evidence of the alleged late payments be provided. My request is supported by the FCRA's 15 U.S.C. 1681.", inline_format: true, styles: :underline, size: 10
        pdf.move_down 10

        if account_details.any?
          pdf.text "Accounts:", size: 14
          pdf.move_down 5

          account_details.each_with_index do |account, index|
            count = index + 1
            pdf.text "<u><b> ##{count}) REMOVE FROM REPORTING NOW ANY OF THE INJURIOUS ASPECTS OF ALLEGATIONS for any item BELOW NOTED:</b></u>", inline_format: true, size: 10
            pdf.move_down 4
            pdf.text " #{account[:name]}, #{account[:number]} is possibly unfairly, not certifiably compliant, and or elsewise unlawfully reported. I demand that you DELETE NOW this item alleging DEROGATORY-conditioned LATE PAYMENTS event as REQUIRED by law!", size: 10
            pdf.text "------------------------------------------------------------------------------------------------------"
            pdf.move_down 20
          end
          # Vertical headers
          vertical_headers = [
            "Bureau <color rgb='ff0000'>* #{Letter::METRO_2_COMPLIANCE_CODES.key('credit_bureau')}</color>",
            "Balance Owed <color rgb='ff0000'>* #{Letter::METRO_2_COMPLIANCE_CODES.key('balance_owed')}</color>",
            "High Credit <color rgb='ff0000'>* #{Letter::METRO_2_COMPLIANCE_CODES.key('high_credit')}</color>",
            "Credit Limit <color rgb='ff0000'>* #{Letter::METRO_2_COMPLIANCE_CODES.key('credit_limit')}</color>",
            "Past Due Amount <color rgb='ff0000'>* #{Letter::METRO_2_COMPLIANCE_CODES.key('past_due_amount')}</color>",
            "Payment Status <color rgb='ff0000'>* #{Letter::METRO_2_COMPLIANCE_CODES.key('payment_status')}</color>",
            "Date Opened <color rgb='ff0000'>* #{Letter::METRO_2_COMPLIANCE_CODES.key('date_opened')}</color>",
            "Date of Last Payment <color rgb='ff0000'>* #{Letter::METRO_2_COMPLIANCE_CODES.key('last_payment')}</color>",
            "Last Reported <color rgb='ff0000'>* #{Letter::METRO_2_COMPLIANCE_CODES.key('date_of_last_activity')}</color>",
            "Creditor Remarks <color rgb='ff0000'>* #{Letter::METRO_2_COMPLIANCE_CODES.key('creditor_remarks')}</color>",
            "Monthly Payment <color rgb='ff0000'>* #{Letter::METRO_2_COMPLIANCE_CODES.key('payment_amount')}</color>"
          ]
    
          account_details.each do |account|
            if account[:bureau_details].none? { |detail| detail[:bureau].casecmp(bureau_name).zero? }
              pdf.text "<u><b># Delete Immediately any Unjust and Harmful Elements of Your Report:</b></u>", inline_format: true, size: 10
              pdf.text "Account Name: #{account[:name]} <color rgb='ff0000'>* #{Letter::METRO_2_COMPLIANCE_CODES.key('creditor_name') if account[:name].present?}</color>", inline_format: true, size: 8
              pdf.text "Account Number: #{account[:number]} <color rgb='ff0000'>* #{Letter::METRO_2_COMPLIANCE_CODES.key('account_number') if account[:number].present?}</color>", background_color: "E8DE5E", inline_format: true, size: 8
              pdf.move_down 10
      
              bureau_table_data = [vertical_headers]
      
              account[:bureau_details].each do |detail|
                bureau_key = bureau_mapping.key(detail[:bureau].downcase)
                bureau_data = [
                  { content: "#{detail[:bureau] || "--"} <color rgb='ff0000'>#{bureau_key}</color>", background_color: bureau_colors[bureau_mapping[bureau_key]] || 'FFFFFF' },
                  "#{detail[:balance_owed] || "--"} <color rgb='ff0000'>#{compliance_codes.sample}</color>",
                  "#{detail[:high_credit] || "--"} <color rgb='ff0000'>#{compliance_codes.sample}</color>",
                  "#{detail[:credit_limit] || "--"} <color rgb='ff0000'>#{compliance_codes.sample}</color>",
                  "#{detail[:past_due_amount] || "--"} <color rgb='ff0000'>#{compliance_codes.sample}</color>",
                  "#{detail[:payment_status] || "--"} <color rgb='ff0000'>#{compliance_codes.sample}</color>",
                  "#{detail[:date_opened] || "--"} <color rgb='ff0000'>#{compliance_codes.sample}</color>",
                  "#{detail[:date_of_last_payment] || "--"} <color rgb='ff0000'>#{compliance_codes.sample}</color>",
                  "#{detail[:last_reported] || "--"} <color rgb='ff0000'>#{compliance_codes.sample}</color>",
                  "#{detail[:comment] || "--"} <color rgb='ff0000'>#{compliance_codes.sample}</color>",
                  "#{detail[:monthly_payment] || "--"} <color rgb='ff0000'>#{compliance_codes.sample}</color>"
                ]
      
                bureau_table_data << bureau_data
              end
            end
    
            # Transpose the table to make headers vertical
            transposed_data = bureau_table_data.transpose
            pdf.table(transposed_data, header: true, row_colors: ['F0F0F0', 'FFFFFF'], cell_style: { inline_format: true, size: 8 })
            pdf.move_down 10
            pdf.text "I am contesting the validity of the derogatory late payment claims unjustly reported against me. My primary concern is that both you and the reporting entity are legally required to maintain and follow processes and procedures that ensure the highest possible accuracy and reliability of all consumer credit information, especially regarding negative or delinquent accounts. I have reasonable suspicion that the claims made by you or the reporting entity lack sufficient evidence to meet the minimum standards of regulatory reporting laws and the required reporting standards, including but not limited to the Metro 2 Format, 15 U.S.C. 1681, Regulation V, and all aspects of 15 U.S.C. 1681s-2. It is imperative that any data furnisher reports fair and accurate information, and must not share information if they know or should know, or have reasonable cause to believe, that the data is inaccurate or questionable.", inline_format: true, styles: [:underline], size: 10
            pdf.move_down 10
            pdf.text "------------------------------------------------------------------------------------------------------"
            pdf.move_down 20
          end
        end

        if public_records.any? { |record| record.bureau_details.any? { |detail| detail[:bureau].casecmp(bureau_name).zero? } }
          pdf.text "Public Records:", size: 14
          pdf.move_down 5

          filtered_public_records = public_records.select do |record|
            record.bureau_details.any? { |detail| detail[:bureau].casecmp(bureau_name).zero? }
          end

          filtered_public_records.each_with_index do |pr, index|
            count = index + 1
            pdf.text "<u><b> ##{count}) REMOVE FROM REPORTING NOW ANY OF THE INJURIOUS ASPECTS OF ALLEGATIONS for any item BELOW NOTED:</b></u>", inline_format: true, size: 10
            pdf.move_down 4
            pdf.text " #{pr[:public_record_type]}, #{pr[:reference_number]} is possibly unfairly, not certifiably compliant, and or elsewise unlawfully reported. I demand that you DELETE NOW this item alleging DEROGATORY-conditioned LATE PAYMENTS event as REQUIRED by law!", size: 10
            pdf.text "------------------------------------------------------------------------------------------------------"
            pdf.move_down 20
          end
          # Vertical headers
          vertical_headers = [
            "Bureau <color rgb='ff0000'>* #{Letter::METRO_2_COMPLIANCE_CODES.key('credit_bureau')}</color>",
            "status <color rgb='ff0000'>*</color>",
            "Date Filed/Reported <color rgb='ff0000'>*</color>",
            "Closing Date <color rgb='ff0000'>*</color>",
            "Asset Amount <color rgb='ff0000'>*</color>",
            "Court <color rgb='ff0000'>*</color>",
            "Liability <color rgb='ff0000'>*</color>",
            "Exempt Amount <color rgb='ff0000'>*</color>"
          ]
    
          public_records.each do |pr|
            pdf.text "<u><b># Delete Immediately any Unjust and Harmful Elements of Your Report:</b></u>", inline_format: true, size: 10
            pdf.text "Account Name: #{pr[:public_record_type]} <color rgb='ff0000'>* #{Letter::METRO_2_COMPLIANCE_CODES.key('creditor_name') if pr[:public_record_type].present?}</color>", inline_format: true, size: 8
            pdf.text "Account Number: #{pr[:reference_number]} <color rgb='ff0000'>* #{Letter::METRO_2_COMPLIANCE_CODES.key('account_number') if pr[:reference_number].present?}</color>", background_color: "E8DE5E", inline_format: true, size: 8
            pdf.move_down 10
    
            bureau_table_data = [vertical_headers]
    
            pr.bureau_details.each do |detail|
              bureau_key = bureau_mapping.key(detail[:bureau].downcase)
              bureau_data = [
                { content: "#{detail[:bureau] || "--"} <color rgb='ff0000'>#{bureau_key}</color>", background_color: bureau_colors[bureau_mapping[bureau_key]] || 'FFFFFF' },
                "#{detail[:status] || "--"} <color rgb='ff0000'>#{compliance_codes.sample}</color>",
                "#{detail[:date_filed_reported] || "--"} <color rgb='ff0000'>#{compliance_codes.sample}</color>",
                "#{detail[:closing_date] || "--"} <color rgb='ff0000'>#{compliance_codes.sample}</color>",
                "#{detail[:asset_amount] || "--"} <color rgb='ff0000'>#{compliance_codes.sample}</color>",
                "#{detail[:court] || "--"} <color rgb='ff0000'>#{compliance_codes.sample}</color>",
                "#{detail[:liability] || "--"} <color rgb='ff0000'>#{compliance_codes.sample}</color>",
                "#{detail[:exempt_amount] || "--"} <color rgb='ff0000'>#{compliance_codes.sample}</color>"
              ]
    
              bureau_table_data << bureau_data
            end
    
            # Transpose the table to make headers vertical
            transposed_data = bureau_table_data.transpose
            pdf.table(transposed_data, header: true, row_colors: ['F0F0F0', 'FFFFFF'], cell_style: { inline_format: true, size: 8 })
            pdf.move_down 10
            pdf.text "I am contesting the validity of the derogatory late payment claims unjustly reported against me. My primary concern is that both you and the reporting entity are legally required to maintain and follow processes and procedures that ensure the highest possible accuracy and reliability of all consumer credit information, especially regarding negative or delinquent accounts. I have reasonable suspicion that the claims made by you or the reporting entity lack sufficient evidence to meet the minimum standards of regulatory reporting laws and the required reporting standards, including but not limited to the Metro 2 Format, 15 U.S.C. 1681, Regulation V, and all aspects of 15 U.S.C. 1681s-2. It is imperative that any data furnisher reports fair and accurate information, and must not share information if they know or should know, or have reasonable cause to believe, that the data is inaccurate or questionable.", inline_format: true, styles: [:underline], size: 10
            pdf.move_down 10
            pdf.text "------------------------------------------------------------------------------------------------------"
            pdf.move_down 20
          end
        end

        pdf.fill_color "5463F0"
        pdf.text "Non-compliance with the Metro 2 compliance standard can result in significant harm to consumers. The Metro 2 format is crucial for ensuring the accuracy and completeness of credit reporting. When credit bureaus or data furnishers fail to adhere to these standards, it can lead to incorrect or incomplete credit information being reported. This can negatively impact an individual's credit score, making it difficult to secure loans, housing, or employment. Such inaccuracies can also lead to higher interest rates and insurance premiums, exacerbating financial hardships. Under the Fair Credit Reporting Act (FCRA), the law imposes stringent penalties for non-compliance. Companies that fail to maintain accurate reporting can face fines of up to $1,000 per violation, and in cases of willful non-compliance, the fines can escalate significantly. Additionally, individuals affected by these inaccuracies have the right to seek damages for any resulting harm. I have personally suffered considerable hardships due to the incompetent behavior of those responsible for maintaining my credit information, highlighting the critical need for strict adherence to these compliance standards to protect consumers' financial well-being."
        pdf.fill_color "000000" 
      end
    end
  
    add_attachments_to_pdf(pdf_path, user)
  
    letter.send(pdf_attachment).attach(io: File.open(pdf_path), filename: "#{bureau_name}_letter#{letter.id}.pdf", content_type: 'application/pdf')
    File.delete(pdf_path) if File.exist?(pdf_path)
  end
  
  def bureau_address(bureau)
    case bureau.downcase
    when 'experian'
      "P.O. Box 4500, Allen, TX 75013"
    when 'transunion'
      "P.O. Box 2000, Chester, PA 19016-2000"
    when 'equifax'
      "P.O. Box 740241, Atlanta, GA 30374-0241"
    else
      "Unknown Bureau"
    end
  end 
  
  def bureau_company(bureau)
    case bureau.downcase
    when 'experian'
      "Experian"
    when 'transunion'
      "Transunion"
    when 'equifax'
      "Equifax"
    else
      "Unknown Bureau"
    end
  end
end
