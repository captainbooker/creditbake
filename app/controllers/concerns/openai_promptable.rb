module OpenaiPromptable
  extend ActiveSupport::Concern

  included do
    before_action :initialize_openai_client
  end

  def send_prompts_for_round(round, inquiries, accounts, public_record)
    {
      experian: send_prompt(round, inquiries, accounts, public_record, 'experian'),
      transunion: send_prompt(round, inquiries, accounts, public_record, 'transunion'),
      equifax: send_prompt(round, inquiries, accounts, public_record, 'equifax')
    }
  end

  private

  def initialize_openai_client
    @client = OpenAI::Client.new(access_token: ENV['OPENAI_ACCESS_TOKEN'])
  end

  def send_prompt(round, inquiries, accounts, public_record, bureau)
  
    prompt = get_prompt(round, inquiries, accounts, public_record, bureau)
    response = @client.chat(
      parameters: {
        model: "gpt-4o",
        messages: [
          { role: "system", content: "You are an AI that generates Metro 2 compliance dispute letters for credit inquiries and accounts." },
          { role: "user", content: prompt }
        ],
        max_tokens: 4096
      }
    )
    response_text = response['choices'].first['message']['content']
    inject_sensitive_data(response_text, current_user.ssn_last4)
  end

  def get_prompt(round, inquiries, accounts, public_record, bureau)
    case round
    when 1 then round_1_prompt(inquiries, accounts, public_record, bureau)
    when 2 then round_2_prompt(inquiries, accounts, public_record, bureau)
    when 3 then round_3_prompt(inquiries, accounts, public_record, bureau)
    when 4 then round_4_prompt(inquiries, accounts, public_record, bureau)
    when 5 then round_5_prompt(inquiries, accounts, public_record, bureau)
    when 6 then round_6_prompt(inquiries, accounts, public_record, bureau)
    when 7 then round_7_prompt(inquiries, accounts, public_record, bureau)
    when 8 then inquiries_all_in(inquiries, accounts, public_record, bureau)
    when 9 then account_validation(inquiries, accounts, public_record, bureau)
    when 10 then final_demand_prompt(inquiries, accounts, public_record, bureau)
    else
      "Invalid round selected."
    end
  end

  def inquiries_all_in(inquiries, accounts, public_record, bureau)
    <<-PROMPT
    You are tasked with generating a unique comprehensive, Metro 2 compliant dispute letter for inquiries that do not belong to me. The letter should be detailed and at least six pages long worth of content/details(dont include page count in response), incorporating relevant laws, Metro 2 codes, and any necessary references. Below are the account and inquiry details that need to be addressed in the letter #{bureau.capitalize}
    
      Create Heading(REQUIRED)
      Name: #{current_user.first_name} #{current_user.last_name}
      street_address: #{current_user.street_address}
      city: #{current_user.city}
      state: #{current_user.state}
      postal_code: #{current_user.postal_code}
      country: "USA"
      SSN Last 4: ###SSN_LAST4### (Include under sender address)
      current_date: #{Date.today.strftime("%B %d, %Y")}
  
      Inquiries:(SHOULD BE LISTED IN LETTER)
      #{format_inquiries(inquiries, bureau, 100)}

      Additional Requirements:
      The letter must include relevant legal references, such as the Fair Credit Reporting Act (FCRA) and any other pertinent federal or state laws.
      It must cite specific Metro 2 codes and explain how the reported information violates these standards.
      The tone of the letter should be professional, assertive, and clear, emphasizing the legal rights of the consumer.
      The letter should request a prompt and thorough investigation, correction, or removal of the disputed information from the credit report.
      Include any necessary supporting documentation references, though the actual documents are not provided here.

      Example Structure:
      Introduction: Brief introduction of the purpose of the letter.
      Consumer Rights Overview: Summary of the consumer's rights under relevant laws.
      Dispute Details: Detailed explanation of the disputed account information.
      Inquiry Dispute: Detailed explanation of the disputed inquiry.
      Legal References: Citation of relevant laws and Metro 2 codes that support the dispute.
      Request for Action: Clear request for investigation and correction of the disputed information.
      Conclusion: Summarize the urgency and importance of resolving the dispute.

      Tone and Style:
      Professional and assertive
      Detailed and thorough
      Legally informed and compliant
      (DO NOT NEED SIGNATURE)
    PROMPT
  end

  def account_validation(inquiries, accounts, public_record, bureau)
    <<-PROMPT
      You are tasked with generating a unique comprehensive Metro 2 account validation letter. The letter should be detailed and at least six pages long worth of content/details(dont include page count in response), incorporating relevant laws, Metro 2 codes, and any necessary references. Below are the account and inquiry details that need to be addressed in the letter #{bureau.capitalize}.

      Create Heading(REQUIRED)
      Name: #{current_user.first_name} #{current_user.last_name}
      street_address: #{current_user.street_address}
      city: #{current_user.city}
      state: #{current_user.state}
      postal_code: #{current_user.postal_code}
      country: "USA"
      SSN Last 4: ###SSN_LAST4### (Include under sender address)
      current_date: #{Date.today.strftime("%B %d, %Y")}
  
  
      Accounts:(SHOULD BE LISTED IN LETTER: Account Name, Account Number, Dispute Reason, Balance Owed, Payment Status, Date Opened)
      #{format_accounts_by_bureau(accounts, bureau, 7)}

      Additional Requirements:
      The letter must include relevant legal references, such as the Fair Credit Reporting Act (FCRA) and any other pertinent federal or state laws.
      It must cite specific Metro 2 codes and explain how the reported information violates these standards.
      The tone of the letter should be professional, assertive, and clear, emphasizing the legal rights of the consumer.
      The letter should request a prompt and thorough investigation, correction, or removal of the disputed information from the credit report.
      Include any necessary supporting documentation references, though the actual documents are not provided here.

      Example Structure:
      Introduction: Brief introduction of the purpose of the letter.
      Consumer Rights Overview: Summary of the consumer's rights under relevant laws.
      Dispute Details: Detailed explanation of the disputed account information.
      Inquiry Dispute: Detailed explanation of the disputed inquiry.
      Legal References: Citation of relevant laws and Metro 2 codes that support the dispute.
      Request for Action: Clear request for investigation and correction of the disputed information.
      Conclusion: Summarize the urgency and importance of resolving the dispute.

      Tone and Style:
      Professional and assertive
      Detailed and thorough
      Legally informed and compliant
      (DO NOT NEED SIGNATURE)
    PROMPT
  end

  def round_1_prompt(inquiries, accounts, public_record, bureau)
    <<-PROMPT
      You are tasked with generating a unique comprehensive, Metro 2 compliant dispute letter. The letter should be detailed and at least six pages long worth of content/details(dont include page count in response), incorporating relevant laws, Metro 2 codes, and any necessary references. Below are the account and inquiry details that need to be addressed in the letter #{bureau.capitalize}

      Create Heading(REQUIRED)
      Name: #{current_user.first_name} #{current_user.last_name}
      street_address: #{current_user.street_address}
      city: #{current_user.city}
      state: #{current_user.state}
      postal_code: #{current_user.postal_code}
      country: "USA"
      SSN Last 4: ###SSN_LAST4### (Include under sender address)
      current_date: #{Date.today.strftime("%B %d, %Y")}

      Inquiries:(SHOULD BE LISTED IN LETTER)
      #{format_inquiries(inquiries, bureau, 100)}
  
  
      Accounts:(SHOULD BE LISTED IN LETTER: Account Name, Account Number, Dispute Reason, Balance Owed, Payment Status, Date Opened)
      #{format_accounts_by_bureau(accounts, bureau, 100)}

      Additional Requirements:
      The letter must include relevant legal references, such as the Fair Credit Reporting Act (FCRA) and any other pertinent federal or state laws.
      It must cite specific Metro 2 codes and explain how the reported information violates these standards.
      The tone of the letter should be professional, assertive, and clear, emphasizing the legal rights of the consumer.
      The letter should request a prompt and thorough investigation, correction, or removal of the disputed information from the credit report.
      Include any necessary supporting documentation references, though the actual documents are not provided here.

      Example Structure:
      Introduction: Brief introduction of the purpose of the letter.
      Consumer Rights Overview: Summary of the consumer's rights under relevant laws.
      Dispute Details: Detailed explanation of the disputed account information.
      Inquiry Dispute: Detailed explanation of the disputed inquiry.
      Legal References: Citation of relevant laws and Metro 2 codes that support the dispute.
      Request for Action: Clear request for investigation and correction of the disputed information.
      Conclusion: Summarize the urgency and importance of resolving the dispute.

      Tone and Style:
      Professional and assertive
      Detailed and thorough
      Legally informed and compliant
      (DO NOT NEED SIGNATURE)
    PROMPT
  end

  def round_2_prompt(inquiries, accounts, public_record, bureau)
    <<-PROMPT
    You are tasked with generating a unique comprehensive Metro 2 reinvestigation letter. The letter should be detailed and at least six pages long worth of content/details(dont include page count in response), incorporating relevant laws, Metro 2 codes, and any necessary references. Below are the account and inquiry details that need to be addressed in the letter #{bureau.capitalize}.

      Create Heading(REQUIRED)
      Name: #{current_user.first_name} #{current_user.last_name}
      street_address: #{current_user.street_address}
      city: #{current_user.city}
      state: #{current_user.state}
      postal_code: #{current_user.postal_code}
      country: "USA"
      SSN Last 4: ###SSN_LAST4### (Include under sender address)
      current_date: #{Date.today.strftime("%B %d, %Y")}

      Inquiries:(SHOULD BE LISTED IN LETTER)
      #{format_inquiries(inquiries, bureau, 5)}

      Accounts:(SHOULD BE LISTED IN LETTER: Account Name, Account Number, Dispute Reason, Balance Owed, Payment Status, Date Opened)
      #{format_accounts_by_bureau(accounts, bureau, 5)}

      Additional Requirements:
      The letter must include relevant legal references, such as the Fair Credit Reporting Act (FCRA) and any other pertinent federal or state laws.
      It must cite specific Metro 2 codes and explain how the reported information violates these standards.
      The tone of the letter should be professional, assertive, and clear, emphasizing the legal rights of the consumer.
      The letter should request a thorough reinvestigation of the disputed information, focusing on Metro 2 compliance.
      Include any necessary supporting documentation references, though the actual documents are not provided here.

      Example Structure:
      Introduction: Brief introduction of the purpose of the letter.
      Consumer Rights Overview: Summary of the consumer's rights under relevant laws.
      Dispute Details: Detailed explanation of the disputed account information.
      Inquiry Dispute: Detailed explanation of the disputed inquiry.
      Legal References: Citation of relevant laws and Metro 2 codes that support the dispute.
      Evidence and Documentation: References to any supporting documents that bolster the dispute.
      Request for Reinvestigation: Clear request for a thorough reinvestigation of the disputed information.
      Conclusion: Summarize the urgency and importance of resolving the dispute.

      Tone and Style:
      Professional and assertive
      Detailed and thorough
      Legally informed and compliant
      (DO NOT NEED SIGNATURE)
    PROMPT
  end

  def round_3_prompt(inquiries, accounts, public_record, bureau)
    <<-PROMPT
      You are tasked with generating a comprehensive Metro 2 compliance review letter. The letter should be detailed and at least six pages long worth of content/details(dont include page count in response), incorporating relevant laws, Metro 2 codes, and any necessary references. Below are the account and inquiry details that need to be addressed in the letter #{bureau.capitalize}.

      Create Heading(REQUIRED)
      Name: #{current_user.first_name} #{current_user.last_name}
      street_address: #{current_user.street_address}
      city: #{current_user.city}
      state: #{current_user.state}
      postal_code: #{current_user.postal_code}
      country: "USA"
      SSN Last 4: ###SSN_LAST4### (Include under sender address)
      current_date: #{Date.today.strftime("%B %d, %Y")}

      Inquiries:(SHOULD BE LISTED IN LETTER)
      #{format_inquiries(inquiries, bureau, 100)}

      Accounts:(SHOULD BE LISTED IN LETTER: Account Name, Account Number, Dispute Reason, Balance Owed, Payment Status, Date Opened)
      #{format_accounts_by_bureau(accounts, bureau, 100)}

      Additional Requirements:
      The letter must include relevant legal references, such as the Fair Credit Reporting Act (FCRA) and any other pertinent federal or state laws.
      It must cite specific Metro 2 codes and explain how the reported information violates these standards.
      The tone of the letter should be professional, assertive, and clear, emphasizing the legal rights of the consumer.
      The letter should request a prompt and thorough investigation, correction, or removal of the disputed information from the credit report.
      Include any necessary supporting documentation references, though the actual documents are not provided here.

      Example Structure:
      Introduction: Brief introduction of the purpose of the letter.
      Consumer Rights Overview: Summary of the consumer's rights under relevant laws.
      Dispute Details: Detailed explanation of the disputed account information.
      Inquiry Dispute: Detailed explanation of the disputed inquiry.
      Legal References: Citation of relevant laws and Metro 2 codes that support the dispute.
      Request for Action: Clear request for investigation and correction of the disputed information.
      Conclusion: Summarize the urgency and importance of resolving the dispute.

      Tone and Style:
      Professional and assertive
      Detailed and thorough
      Legally informed and compliant
      (DO NOT NEED SIGNATURE)
    PROMPT
  end

  def round_4_prompt(inquiries, accounts, public_record, bureau)
    <<-PROMPT
      You are tasked with generating a comprehensive Metro 2 dispute escalation and threaten to file a complaint letter. The letter should be detailed and at least six pages long worth of content/details(dont include page count in response), incorporating relevant laws, Metro 2 codes, and any necessary references. Below are the account and inquiry details that need to be addressed in the letter #{bureau.capitalize}.

      Create Heading(REQUIRED)
      Name: #{current_user.first_name} #{current_user.last_name}
      street_address: #{current_user.street_address}
      city: #{current_user.city}
      state: #{current_user.state}
      postal_code: #{current_user.postal_code}
      country: "USA"
      SSN Last 4: ###SSN_LAST4### (Include under sender address)
      current_date: #{Date.today.strftime("%B %d, %Y")}

      Inquiries:(SHOULD BE LISTED IN LETTER)
      #{format_inquiries(inquiries, bureau, 10)}

      Accounts: (SHOULD BE LISTED IN LETTER: Account Name, Account Number, Dispute Reason, Balance Owed, Payment Status, Date Opened)
      #{format_accounts_by_bureau(accounts, bureau, 4)}

      Additional Requirements:
      The letter must include relevant legal references, such as the Fair Credit Reporting Act (FCRA) and any other pertinent federal or state laws.
      It must cite specific Metro 2 codes and explain how the reported information violates these standards.
      The tone of the letter should be professional, assertive, and clear, emphasizing the legal rights of the consumer.
      The letter should request a prompt and thorough investigation, correction, or removal of the disputed information from the credit report.
      Include any necessary supporting documentation references, though the actual documents are not provided here.

      Example Structure:
      Introduction: Brief introduction of the purpose of the letter.
      Consumer Rights Overview: Summary of the consumer's rights under relevant laws.
      Dispute Details: Detailed explanation of the disputed account information.
      Inquiry Dispute: Detailed explanation of the disputed inquiry.
      Legal References: Citation of relevant laws and Metro 2 codes that support the dispute.
      Request for Action: Clear request for investigation and correction of the disputed information.
      Conclusion: Summarize the urgency and importance of resolving the dispute.

      Tone and Style:
      Professional and assertive
      Detailed and thorough
      Legally informed and compliant
      (DO NOT NEED SIGNATURE)
    PROMPT
  end

  def round_5_prompt(inquiries, accounts, public_record, bureau)
    <<-PROMPT
      You are tasked with generating a comprehensive Metro 2 data reconciliation letter. The letter should be detailed and at least six pages long worth of content/details(dont include page count in response), incorporating relevant laws, Metro 2 codes, and any necessary references. Below are the account and inquiry details that need to be addressed in the letter #{bureau.capitalize}.

      Create Heading(REQUIRED)
      Name: #{current_user.first_name} #{current_user.last_name}
      street_address: #{current_user.street_address}
      city: #{current_user.city}
      state: #{current_user.state}
      postal_code: #{current_user.postal_code}
      country: "USA"
      SSN Last 4: ###SSN_LAST4### (Include under sender address)
      current_date: #{Date.today.strftime("%B %d, %Y")}

      Inquiries:(SHOULD BE LISTED IN LETTER)
      #{format_inquiries(inquiries, bureau, 4)}

      Accounts:(SHOULD BE LISTED IN LETTER: Account Name, Account Number, Dispute Reason, Balance Owed, Payment Status, Date Opened)
      #{format_accounts_by_bureau(accounts, bureau, 10)}

      Additional Requirements:
      The letter must include relevant legal references, such as the Fair Credit Reporting Act (FCRA) and any other pertinent federal or state laws.
      It must cite specific Metro 2 codes and explain how the reported information violates these standards.
      The tone of the letter should be professional, assertive, and clear, emphasizing the legal rights of the consumer.
      The letter should request a prompt and thorough investigation, correction, or removal of the disputed information from the credit report.
      Include any necessary supporting documentation references, though the actual documents are not provided here.

      Example Structure:
      Introduction: Brief introduction of the purpose of the letter.
      Consumer Rights Overview: Summary of the consumer's rights under relevant laws.
      Dispute Details: Detailed explanation of the disputed account information.
      Inquiry Dispute: Detailed explanation of the disputed inquiry.
      Legal References: Citation of relevant laws and Metro 2 codes that support the dispute.
      Request for Action: Clear request for investigation and correction of the disputed information.
      Conclusion: Summarize the urgency and importance of resolving the dispute.

      Tone and Style:
      Professional and assertive
      Detailed and thorough
      Legally informed and compliant
      (DO NOT NEED SIGNATURE)
    PROMPT
  end

  def round_6_prompt(inquiries, accounts public_record, bureau)
    <<-PROMPT
      You are tasked with generating a comprehensive Metro 2 dispute resolution demand letter. The letter should be detailed and at least six pages long worth of content/details(dont include page count in response), incorporating relevant laws, Metro 2 codes, and any necessary references. Below are the account and inquiry details that need to be addressed in the letter #{bureau.capitalize}.

      Create Heading(REQUIRED)
      Name: #{current_user.first_name} #{current_user.last_name}
      street_address: #{current_user.street_address}
      city: #{current_user.city}
      state: #{current_user.state}
      postal_code: #{current_user.postal_code}
      country: "USA"
      SSN Last 4: ###SSN_LAST4### (Include under sender address)
      current_date: #{Date.today.strftime("%B %d, %Y")}

      Inquiries:(SHOULD BE LISTED IN LETTER)
      #{format_inquiries(inquiries, bureau, 100)}

      Accounts:(SHOULD BE LISTED IN LETTER: Account Name, Account Number, Dispute Reason, Balance Owed, Payment Status, Date Opened)
      #{format_accounts_by_bureau(accounts, bureau, 100)}

      Additional Requirements:
      The letter must include relevant legal references, such as the Fair Credit Reporting Act (FCRA) and any other pertinent federal or state laws.
      It must cite specific Metro 2 codes and explain how the reported information violates these standards.
      The tone of the letter should be professional, assertive, and clear, emphasizing the legal rights of the consumer.
      The letter should request a prompt and thorough investigation, correction, or removal of the disputed information from the credit report.
      Include any necessary supporting documentation references, though the actual documents are not provided here.

      Example Structure:
      Introduction: Brief introduction of the purpose of the letter.
      Consumer Rights Overview: Summary of the consumer's rights under relevant laws.
      Dispute Details: Detailed explanation of the disputed account information.
      Inquiry Dispute: Detailed explanation of the disputed inquiry.
      Legal References: Citation of relevant laws and Metro 2 codes that support the dispute.
      Request for Action: Clear request for investigation and correction of the disputed information.
      Conclusion: Summarize the urgency and importance of resolving the dispute.

      Tone and Style:
      Professional and assertive
      Detailed and thorough
      Legally informed and compliant
      (DO NOT NEED SIGNATURE)
    PROMPT
  end

  def round_7_prompt(inquiries, accounts, public_record, bureau)
    <<-PROMPT
      You are tasked with generating a comprehensive Metro 2 compliance and accuracy verification letter. The letter should be detailed and at least six pages long worth of content/details(dont include page count in response), incorporating relevant laws, Metro 2 codes, and any necessary references. Below are the account and inquiry details that need to be addressed in the letter #{bureau.capitalize}

      Create Heading(REQUIRED)
      Name: #{current_user.first_name} #{current_user.last_name}
      street_address: #{current_user.street_address}
      city: #{current_user.city}
      state: #{current_user.state}
      postal_code: #{current_user.postal_code}
      country: "USA"
      SSN Last 4: ###SSN_LAST4### (Include under sender address)
      current_date: #{Date.today.strftime("%B %d, %Y")}

      Inquiries:(SHOULD BE LISTED IN LETTER)
      #{format_inquiries(inquiries, bureau, 15)}

      Accounts:(SHOULD BE LISTED IN LETTER: Account Name, Account Number, Dispute Reason, Balance Owed, Payment Status, Date Opened)
      #{format_accounts_by_bureau(accounts, bureau, 8)}

      Additional Requirements:
      The letter must include relevant legal references, such as the Fair Credit Reporting Act (FCRA) and any other pertinent federal or state laws.
      It must cite specific Metro 2 codes and explain how the reported information violates these standards.
      The tone of the letter should be professional, assertive, and clear, emphasizing the legal rights of the consumer.
      The letter should request a prompt and thorough investigation, correction, or removal of the disputed information from the credit report.
      Include any necessary supporting documentation references, though the actual documents are not provided here.

      Example Structure:
      Introduction: Brief introduction of the purpose of the letter.
      Consumer Rights Overview: Summary of the consumer's rights under relevant laws.
      Dispute Details: Detailed explanation of the disputed account information.
      Inquiry Dispute: Detailed explanation of the disputed inquiry.
      Legal References: Citation of relevant laws and Metro 2 codes that support the dispute.
      Request for Action: Clear request for investigation and correction of the disputed information.
      Conclusion: Summarize the urgency and importance of resolving the dispute.

      Tone and Style:
      Professional and assertive
      Detailed and thorough
      Legally informed and compliant
      (DO NOT NEED SIGNATURE)
    PROMPT
  end

  def final_demand_prompt(inquiries, accounts, public_record, bureau)
    <<-PROMPT
    You are tasked with generating a comprehensive, final demand for resolution letter or threaten to go to court. The letter should be detailed and at least six pages long worth of content/details(dont include page count in response, incorporating relevant laws, Metro 2 codes, and any necessary references. Below are the account and inquiry details that need to be addressed in the letter #{bureau.capitalize}

      Create Heading(REQUIRED)
      Name: #{current_user.first_name} #{current_user.last_name}
      street_address: #{current_user.street_address}
      city: #{current_user.city}
      state: #{current_user.state}
      postal_code: #{current_user.postal_code}
      country: "USA"
      SSN Last 4: ###SSN_LAST4### (Include under sender address)
      current_date: #{Date.today.strftime("%B %d, %Y")}

      Inquiries:(SHOULD BE LISTED IN LETTER)
      #{format_inquiries(inquiries, bureau, 100)}

      Accounts:(SHOULD BE LISTED IN LETTER: Account Name, Account Number, Dispute Reason, Balance Owed, Payment Status, Date Opened)
      #{format_accounts_by_bureau(accounts, bureau, 100)}

      Additional Requirements:
      The letter must include relevant legal references, such as the Fair Credit Reporting Act (FCRA) and any other pertinent federal or state laws.
      It must cite specific Metro 2 codes and explain how the reported information violates these standards.
      The tone of the letter should be professional, assertive, and clear, emphasizing the legal rights of the consumer.
      The letter should request a prompt and thorough investigation, correction, or removal of the disputed information from the credit report.
      Include any necessary supporting documentation references, though the actual documents are not provided here.

      Example Structure:
      Introduction: Brief introduction of the purpose of the letter.
      Consumer Rights Overview: Summary of the consumer's rights under relevant laws.
      Dispute Details: Detailed explanation of the disputed account information.
      Inquiry Dispute: Detailed explanation of the disputed inquiry.
      Legal References: Citation of relevant laws and Metro 2 codes that support the dispute.
      Request for Action: Clear request for investigation and correction of the disputed information.
      Conclusion: Summarize the urgency and importance of resolving the dispute.

      Tone and Style:
      Professional and assertive
      Detailed and thorough
      Legally informed and compliant
      (DO NOT NEED SIGNATURE)
    PROMPT
  end

  def format_inquiries(inquiries, bureau, limit = 5)
    inquiries.select { |inquiry| inquiry[:bureau].downcase == bureau.downcase }
             .first(limit)
             .map { |inquiry| "- Name: #{inquiry[:name]}, Bureau: #{inquiry[:bureau].capitalize}" }
             .join("\n")
  end
  

  def format_accounts_by_bureau(accounts, bureau, limit = 5)
    bureau_accounts = accounts.select do |account|
      account[:bureau_details].any? { |detail| detail[:bureau].downcase == bureau.downcase }
    end

    bureau_accounts.first(limit).map do |account|
      details = account[:bureau_details].find { |detail| detail[:bureau].downcase == bureau.downcase }
      <<-DETAILS
        Account Name: #{account[:name]}
        Account Number: #{account[:number]}
        Dispute Reason: #{account[:reason]}
        Balance Owed: #{details[:balance_owed] || '-'}
        Payment Status: #{details[:payment_status] || '-'}
        Date Opened: #{details[:date_opened] || '-'}
      DETAILS
    end.join("\n\n")
  end

  def inject_sensitive_data(letter_text, ssn_last4)
    placeholder = "###SSN_LAST4###"
    letter_text.gsub(placeholder, ssn_last4)
  end
end
