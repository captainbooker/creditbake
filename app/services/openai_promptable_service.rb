class OpenaiPromptableService

  def initialize(user)
    @user = user
    @client = OpenAI::Client.new(access_token: ENV['OPENAI_ACCESS_TOKEN'])
  end

  def send_prompts_for_round(round, inquiries, accounts, public_record)
    if [11, 12].include?(round)
      {
        bankruptcy: send_prompt(round, inquiries, accounts, public_record, 'bankruptcy')
      }
    else
      {
        experian: send_prompt(round, inquiries, accounts, public_record, 'experian'),
        transunion: send_prompt(round, inquiries, accounts, public_record, 'transunion'),
        equifax: send_prompt(round, inquiries, accounts, public_record, 'equifax')
      }
    end
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
          { role: "system", content: "You will be provided with information that range from Inquiries, Accounts and Bankruptcy. Your task is to research metro 2 complaince codes and FCRA laws based on the reason that is provided. Your response should be at least 20 paragraphs." },
          { role: "user", content: prompt }
        ],
        max_tokens: 4096
      }
    )
    response_text = response['choices'].first['message']['content']
    inject_sensitive_data(response_text, @user.ssn_last4)
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
    when 11 then bankrupcty_step_1(public_record, bureau)
    when 12 then bankrupcty_step_2(public_record, bureau)
    else
      "Invalid round selected."
    end
  end

  def inquiries_all_in(inquiries, accounts, public_record, bureau)
    <<-PROMPT
      
      Requirement: Create a professional, ready-to-send dispute letter.
      Name: #{@user.first_name} #{@user.last_name}
      Street Address: #{@user.street_address}
      City: #{@user.city}
      State: #{@user.state}
      Postal Code: #{@user.postal_code}
      Country: "USA"
      SSN Last 4: ###SSN_LAST4### (Include under sender address)
      Current Date: #{Date.today.strftime("%B %d, %Y")}

      Information:
      Inquiries: (SHOULD BE LISTED)
      #{format_inquiries(inquiries, bureau, 100)}

      Additional Requirements:
      - Your response must include relevant legal references, such as the Fair Credit Reporting Act (FCRA) and any other pertinent federal or state laws.
      - It must cite specific Metro 2 codes and explain how the reported information violates these standards.
      - The tone of your response should be professional, assertive, and clear, emphasizing the legal rights of the consumer.
      - Your response should request a prompt and thorough investigation, correction, or removal of the disputed information from the credit report.
      - Include any necessary supporting documentation references, though the actual documents are not provided here.

      Example Structure (without special characters like ### or headings within the text):
      1. Introduction: Brief introduction of the purpose of your response.
      2. Consumer Rights Overview: Summary of the consumer's rights under relevant laws.
      3. Dispute Details: Detailed explanation of the disputed account information.
      4. Inquiry Dispute: Detailed explanation of the disputed inquiry.
      5. Legal References: Citation of relevant laws and Metro 2 codes that support the dispute.
      6. Request for Action: Clear request for investigation and correction of the disputed information.
      7. Conclusion: Summarize the urgency and importance of resolving the dispute.

      Tone and Style:
      - Professional and assertive
      - Detailed and thorough
      - Legally informed and compliant

      Note: Do not include special characters or multiple headings within the text.

    PROMPT
  end

  def account_validation(inquiries, accounts, public_record, bureau)
    <<-PROMPT
      Generate a unique, comprehensive Metro 2 account validation letter for #{bureau.capitalize}. Ensure the final output does not include special characters like ``` or ###.
  
      Requirement: Create a professional, ready-to-send letter with the following details:
      Name: #{@user.first_name} #{@user.last_name}
      Street Address: #{@user.street_address}
      City: #{@user.city}
      State: #{@user.state}
      Postal Code: #{@user.postal_code}
      Country: "USA"
      SSN Last 4: ###SSN_LAST4### (Include under sender address)
      Current Date: #{Date.today.strftime("%B %d, %Y")}
  
      Information: List accounts and public records details in the letter as provided:
      #{format_accounts_by_bureau(accounts, bureau, 7)}
  
      #{format_public_records_by_bureau(public_record, bureau)}
  
      Additional Requirements:
      - The letter must include relevant legal references, such as the Fair Credit Reporting Act (FCRA) and any other pertinent federal or state laws.
      - It must cite specific Metro 2 codes and explain how the reported information violates these standards.
      - The tone of the letter should be professional, assertive, and clear, emphasizing the legal rights of the consumer.
      - The letter should request a prompt and thorough investigation, correction, or removal of the disputed information from the credit report.
      - Include any necessary supporting documentation references, though the actual documents are not provided here.
  
      Example Structure (without special characters or extra headings):
      - **Introduction**: Brief introduction of the purpose of the letter.
      - **Consumer Rights Overview**: Summary of the consumer's rights under relevant laws.
      - **Dispute Details**: Detailed explanation of the disputed account information.
      - **Inquiry Dispute**: Detailed explanation of the disputed inquiry.
      - **Legal References**: Citation of relevant laws and Metro 2 codes that support the dispute.
      - **Request for Action**: Clear request for investigation and correction of the disputed information.
      - **Conclusion**: Summarize the urgency and importance of resolving the dispute.
  
      Tone and Style:
      - Professional and assertive
      - Detailed and thorough
      - Legally informed and compliant
  
      Note: Do not include special characters like ``` or ### or multiple headings within the text.
    PROMPT
  end
  

  def round_1_prompt(inquiries, accounts, public_record, bureau)
    <<-PROMPT
      Generate a unique, comprehensive, Metro 2 compliant dispute letter for #{bureau.capitalize}. Ensure the final output does not include special characters like ``` or ###.

      Requirement: Create a professional, ready-to-send letter with the following details:
      Name: #{@user.first_name} #{@user.last_name}
      Street Address: #{@user.street_address}
      City: #{@user.city}
      State: #{@user.state}
      Postal Code: #{@user.postal_code}
      Country: "USA"
      SSN Last 4: ###SSN_LAST4### (Include under sender address)
      Current Date: #{Date.today.strftime("%B %d, %Y")}

      Information: List inquiry, accounts, and public records details in the letter:
      #{format_inquiries(inquiries, bureau, 100)}
      #{format_accounts_by_bureau(accounts, bureau, 100)}
      #{format_public_records_by_bureau(public_record, bureau)}

      Additional Requirements:
      - The letter must include relevant legal references, such as the Fair Credit Reporting Act (FCRA) and any other pertinent federal or state laws.
      - It must cite specific Metro 2 codes and explain how the reported information violates these standards.
      - The tone of the letter should be professional, assertive, and clear, emphasizing the legal rights of the consumer.
      - The letter should request a prompt and thorough investigation, correction, or removal of the disputed information from the credit report.
      - Include any necessary supporting documentation references, though the actual documents are not provided here.

      Example Structure (use plain text without special characters or multiple headings):
      1. Introduction: Brief introduction of the purpose of the letter.
      2. Consumer Rights Overview: Summary of the consumer's rights under relevant laws.
      3. Dispute Details: Detailed explanation of the disputed account information.
      4. Inquiry Dispute: Detailed explanation of the disputed inquiry.
      5. Legal References: Citation of relevant laws and Metro 2 codes that support the dispute.
      6. Request for Action: Clear request for investigation and correction of the disputed information.
      7. Conclusion: Summarize the urgency and importance of resolving the dispute.

      Tone and Style:
      - Professional and assertive
      - Detailed and thorough
      - Legally informed and compliant

      Note: Do not include special characters like ``` or ### or multiple headings within the text.
    PROMPT
  end


  def round_2_prompt(inquiries, accounts, public_record, bureau)
    <<-PROMPT
      Generate a unique, comprehensive Metro 2 reinvestigation letter for #{bureau.capitalize}. Ensure the final output does not include special characters like ``` or ###, and does not have multiple redundant headings.
  
      Requirement: Create a professional, ready-to-send letter with the following details:
      Name: #{@user.first_name} #{@user.last_name}
      Street Address: #{@user.street_address}
      City: #{@user.city}
      State: #{@user.state}
      Postal Code: #{@user.postal_code}
      Country: "USA"
      SSN Last 4: ###SSN_LAST4### (Include under sender address)
      Current Date: #{Date.today.strftime("%B %d, %Y")}
  
      Information: List inquiry, accounts, and public records details in the letter:
      #{format_inquiries(inquiries, bureau, 5)}
      #{format_accounts_by_bureau(accounts, bureau, 5)}
      #{format_public_records_by_bureau(public_record, bureau)}
  
      Additional Requirements:
      - The letter must include relevant legal references, such as the Fair Credit Reporting Act (FCRA) and any other pertinent federal or state laws.
      - It must cite specific Metro 2 codes and explain how the reported information violates these standards.
      - The tone of the letter should be professional, assertive, and clear, emphasizing the legal rights of the consumer.
      - The letter should request a thorough reinvestigation of the disputed information, focusing on Metro 2 compliance.
      - Include any necessary supporting documentation references, though the actual documents are not provided here.
  
      Example Structure (without special characters or redundant headings):
      1. **Introduction**: Brief introduction of the purpose of the letter.
      2. **Consumer Rights Overview**: Summary of the consumer's rights under relevant laws.
      3. **Dispute Details**: Detailed explanation of the disputed account information.
      4. **Inquiry Dispute**: Detailed explanation of the disputed inquiry.
      5. **Legal References**: Citation of relevant laws and Metro 2 codes that support the dispute.
      6. **Evidence and Documentation**: References to any supporting documents that bolster the dispute.
      7. **Request for Reinvestigation**: Clear request for a thorough reinvestigation of the disputed information.
      8. **Conclusion**: Summarize the urgency and importance of resolving the dispute.
  
      Tone and Style:
      - Professional and assertive
      - Detailed and thorough
      - Legally informed and compliant
  
      Note: Do not include special characters like ``` or ###, and avoid multiple redundant headings within the text.
    PROMPT
  end
  

  def round_3_prompt(inquiries, accounts, public_record, bureau)
    <<-PROMPT
      Generate a comprehensive Metro 2 compliance review letter for #{bureau.capitalize}. The final output must not include special characters like ``` or ### and should avoid redundant headings.
  
      Requirement: Create a professional, ready-to-send letter with the following details:
      Name: #{@user.first_name} #{@user.last_name}
      Street Address: #{@user.street_address}
      City: #{@user.city}
      State: #{@user.state}
      Postal Code: #{@user.postal_code}
      Country: "USA"
      SSN Last 4: ###SSN_LAST4### (Include under sender address)
      Current Date: #{Date.today.strftime("%B %d, %Y")}
  
      Information: List inquiry, accounts, and public records details in the letter:
      #{format_inquiries(inquiries, bureau, 100)}
      #{format_accounts_by_bureau(accounts, bureau, 100)}
      #{format_public_records_by_bureau(public_record, bureau)}
  
      Additional Requirements:
      - Include relevant legal references, such as the Fair Credit Reporting Act (FCRA) and any other pertinent federal or state laws.
      - Cite specific Metro 2 codes and explain how the reported information violates these standards.
      - Use a professional, assertive, and clear tone, emphasizing the legal rights of the consumer.
      - Request a prompt and thorough investigation, correction, or removal of the disputed information from the credit report.
      - Reference any necessary supporting documentation, though the actual documents are not provided here.
  
      Structure of the Letter (use plain text without special characters or multiple headings):
      1. Introduction: Brief introduction of the purpose of the letter.
      2. Consumer Rights Overview: Summary of the consumer's rights under relevant laws.
      3. Dispute Details: Detailed explanation of the disputed account information.
      4. Inquiry Dispute: Detailed explanation of the disputed inquiry.
      5. Legal References: Citation of relevant laws and Metro 2 codes that support the dispute.
      6. Request for Action: Clear request for investigation and correction of the disputed information.
      7. Conclusion: Summarize the urgency and importance of resolving the dispute.
  
      Tone and Style:
      - Professional and assertive
      - Detailed and thorough
      - Legally informed and compliant
  
      Note: Do not include special characters like ``` or ###, and avoid multiple redundant headings within the text.
    PROMPT
  end
  

  def round_4_prompt(inquiries, accounts, public_record, bureau)
    <<-PROMPT
      Generate a comprehensive Metro 2 dispute escalation letter for #{bureau.capitalize}. The final output must not include special characters like ``` or ###, and should avoid redundant headings.
  
      Requirement: Create a professional, ready-to-send letter with the following details:
      Name: #{@user.first_name} #{@user.last_name}
      Street Address: #{@user.street_address}
      City: #{@user.city}
      State: #{@user.state}
      Postal Code: #{@user.postal_code}
      Country: "USA"
      SSN Last 4: ###SSN_LAST4### (Include under sender address)
      Current Date: #{Date.today.strftime("%B %d, %Y")}
  
      Information: List inquiry, accounts, and public records details in the letter:
      #{format_inquiries(inquiries, bureau, 10)}
      #{format_accounts_by_bureau(accounts, bureau, 4)}
      #{format_public_records_by_bureau(public_record, bureau)}
  
      Additional Requirements:
      - Include relevant legal references, such as the Fair Credit Reporting Act (FCRA) and any other pertinent federal or state laws.
      - Cite specific Metro 2 codes and explain how the reported information violates these standards.
      - Use a professional, assertive, and clear tone, emphasizing the legal rights of the consumer.
      - Request a prompt and thorough investigation, correction, or removal of the disputed information from the credit report.
      - Reference any necessary supporting documentation, though the actual documents are not provided here.
  
      Structure of the Letter (use plain text without special characters or redundant headings):
      1. Introduction: Brief introduction of the purpose of the letter.
      2. Consumer Rights Overview: Summary of the consumer's rights under relevant laws.
      3. Dispute Details: Detailed explanation of the disputed account information.
      4. Inquiry Dispute: Detailed explanation of the disputed inquiry.
      5. Legal References: Citation of relevant laws and Metro 2 codes that support the dispute.
      6. Request for Action: Clear request for investigation and correction of the disputed information.
      7. Conclusion: Summarize the urgency and importance of resolving the dispute.
  
      Tone and Style:
      - Professional and assertive
      - Detailed and thorough
      - Legally informed and compliant
  
      Note: Do not include special characters like ``` or ###, and avoid multiple redundant headings within the text.
    PROMPT
  end  

  def round_5_prompt(inquiries, accounts, public_record, bureau)
    <<-PROMPT
      Generate a comprehensive Metro 2 data reconciliation letter for #{bureau.capitalize}. Ensure the final output does not include special characters like ``` or ###, and avoid redundant headings.
  
      Requirement: Create a professional, ready-to-send letter with the following details:
      Name: #{@user.first_name} #{@user.last_name}
      Street Address: #{@user.street_address}
      City: #{@user.city}
      State: #{@user.state}
      Postal Code: #{@user.postal_code}
      Country: "USA"
      SSN Last 4: ###SSN_LAST4### (Include under sender address)
      Current Date: #{Date.today.strftime("%B %d, %Y")}
  
      Information: Include the details of inquiries, accounts, and public records as provided:
      #{format_inquiries(inquiries, bureau, 4)}
      #{format_accounts_by_bureau(accounts, bureau, 10)}
      #{format_public_records_by_bureau(public_record, bureau)}
  
      Additional Requirements:
      - Include relevant legal references, such as the Fair Credit Reporting Act (FCRA) and any other pertinent federal or state laws.
      - Cite specific Metro 2 codes and explain how the reported information violates these standards.
      - Use a professional, assertive, and clear tone, emphasizing the legal rights of the consumer.
      - Request a prompt and thorough investigation, correction, or removal of the disputed information from the credit report.
      - Reference any necessary supporting documentation, though the actual documents are not provided here.
  
      Structure of the Letter (do not include special characters like ``` or ###, and avoid redundant headings):
      1. **Introduction**: Brief introduction of the purpose of the letter.
      2. **Consumer Rights Overview**: Summary of the consumer's rights under relevant laws.
      3. **Dispute Details**: Detailed explanation of the disputed account information.
      4. **Inquiry Dispute**: Detailed explanation of the disputed inquiry.
      5. **Legal References**: Citation of relevant laws and Metro 2 codes that support the dispute.
      6. **Request for Action**: Clear request for investigation and correction of the disputed information.
      7. **Conclusion**: Summarize the urgency and importance of resolving the dispute.
  
      Tone and Style:
      - Professional and assertive
      - Detailed and thorough
      - Legally informed and compliant
  
      Note: Do not include special characters like ``` or ###, and avoid multiple redundant headings within the text.
    PROMPT
  end  

  def round_6_prompt(inquiries, accounts, public_record, bureau)
    <<-PROMPT
      Generate a comprehensive Metro 2 dispute resolution demand letter for #{bureau.capitalize}. The final output must not include special characters like ``` or ###, and should avoid redundant headings.
  
      Requirement: Create a professional, ready-to-send letter with the following details:
      Name: #{@user.first_name} #{@user.last_name}
      Street Address: #{@user.street_address}
      City: #{@user.city}
      State: #{@user.state}
      Postal Code: #{@user.postal_code}
      Country: "USA"
      SSN Last 4: ###SSN_LAST4### (Include under sender address)
      Current Date: #{Date.today.strftime("%B %d, %Y")}
  
      Information: Include the details of inquiries, accounts, and public records as provided:
      #{format_inquiries(inquiries, bureau, 100)}
      #{format_accounts_by_bureau(accounts, bureau, 100)}
      #{format_public_records_by_bureau(public_record, bureau)}
  
      Additional Requirements:
      - Include relevant legal references, such as the Fair Credit Reporting Act (FCRA) and any other pertinent federal or state laws.
      - Cite specific Metro 2 codes and explain how the reported information violates these standards.
      - Use a professional, assertive, and clear tone, emphasizing the legal rights of the consumer.
      - Request a prompt and thorough investigation, correction, or removal of the disputed information from the credit report.
      - Reference any necessary supporting documentation, though the actual documents are not provided here.
  
      Structure of the Letter (without special characters or redundant headings):
      1. Introduction: Brief introduction of the purpose of the letter.
      2. Consumer Rights Overview: Summary of the consumer's rights under relevant laws.
      3. Dispute Details: Detailed explanation of the disputed account information.
      4. Inquiry Dispute: Detailed explanation of the disputed inquiry.
      5. Legal References: Citation of relevant laws and Metro 2 codes that support the dispute.
      6. Request for Action: Clear request for investigation and correction of the disputed information.
      7. Conclusion: Summarize the urgency and importance of resolving the dispute.
  
      Tone and Style:
      - Professional and assertive
      - Detailed and thorough
      - Legally informed and compliant
  
      Important: Do not include special characters like ``` or ###. Avoid multiple redundant headings within the text.
    PROMPT
  end  

  def round_7_prompt(inquiries, accounts, public_record, bureau)
    <<-PROMPT
      You are tasked with generating a comprehensive Metro 2 compliance and accuracy verification letter for #{bureau.capitalize}. Ensure that the final output does not include special characters like ``` or ### and does not have multiple redundant headings.
  
      Requirement: Create a professional, ready-to-send letter with the following details:
      Name: #{@user.first_name} #{@user.last_name}
      Street Address: #{@user.street_address}
      City: #{@user.city}
      State: #{@user.state}
      Postal Code: #{@user.postal_code}
      Country: "USA"
      SSN Last 4: ###SSN_LAST4### (Include under sender address)
      Current Date: #{Date.today.strftime("%B %d, %Y")}
  
      Information: Include the details of inquiries, accounts, and public records as provided:
      #{format_inquiries(inquiries, bureau, 15)}
      #{format_accounts_by_bureau(accounts, bureau, 8)}
      #{format_public_records_by_bureau(public_record, bureau)}
  
      Additional Requirements:
      - Include relevant legal references, such as the Fair Credit Reporting Act (FCRA) and any other pertinent federal or state laws.
      - Cite specific Metro 2 codes and explain how the reported information violates these standards.
      - Use a professional, assertive, and clear tone, emphasizing the legal rights of the consumer.
      - Request a prompt and thorough investigation, correction, or removal of the disputed information from the credit report.
      - Reference any necessary supporting documentation, though the actual documents are not provided here.
  
      Structure of the Letter (without special characters or redundant headings):
      1. **Introduction**: Brief introduction of the purpose of the letter.
      2. **Consumer Rights Overview**: Summary of the consumer's rights under relevant laws.
      3. **Dispute Details**: Detailed explanation of the disputed account information.
      4. **Inquiry Dispute**: Detailed explanation of the disputed inquiry.
      5. **Legal References**: Citation of relevant laws and Metro 2 codes that support the dispute.
      6. **Request for Action**: Clear request for investigation and correction of the disputed information.
      7. **Conclusion**: Summarize the urgency and importance of resolving the dispute.
  
      Tone and Style:
      - Professional and assertive
      - Detailed and thorough
      - Legally informed and compliant
  
      Important: Do not include special characters like ``` or ###. Avoid multiple redundant headings within the text. Ensure the letter is clear and well-structured, following the outline provided above.
    PROMPT
  end  

  def final_demand_prompt(inquiries, accounts, public_record, bureau)
    <<-PROMPT
      You are tasked with generating a comprehensive, final demand for resolution letter or threat to go to court for #{bureau.capitalize}. Ensure that the final output does not include special characters like ``` or ### and does not contain redundant headings.
  
      Requirements:
      - Create a professional, ready-to-send letter with the following details:
        - Name: #{@user.first_name} #{@user.last_name}
        - Street Address: #{@user.street_address}
        - City: #{@user.city}
        - State: #{@user.state}
        - Postal Code: #{@user.postal_code}
        - Country: "USA"
        - SSN Last 4: ###SSN_LAST4### (Include under the sender address)
        - Current Date: #{Date.today.strftime("%B %d, %Y")}
  
      - Information to include in the letter:
        - List details of inquiries, accounts, and public records provided:
          #{format_inquiries(inquiries, bureau, 100)}
          #{format_accounts_by_bureau(accounts, bureau, 100)}
          #{format_public_records_by_bureau(public_record, bureau)}
  
      - Additional Requirements:
        - Include relevant legal references, such as the Fair Credit Reporting Act (FCRA) and other pertinent federal or state laws.
        - Cite specific Metro 2 codes and explain how the reported information violates these standards.
        - Maintain a professional, assertive, and clear tone, emphasizing the consumer's legal rights.
        - Request a prompt and thorough investigation, correction, or removal of the disputed information from the credit report.
        - Reference any necessary supporting documentation, though actual documents are not provided.
  
      - Structure of the Letter:
        - **Introduction**: Briefly state the purpose of the letter.
        - **Consumer Rights Overview**: Summarize the consumer's rights under relevant laws.
        - **Dispute Details**: Explain the disputed account information.
        - **Inquiry Dispute**: Detail the disputed inquiry.
        - **Legal References**: Cite relevant laws and Metro 2 codes that support the dispute.
        - **Request for Action**: Request for investigation and correction of the disputed information.
        - **Conclusion**: Emphasize the urgency and importance of resolving the dispute.
  
      - Tone and Style:
        - Professional and assertive
        - Detailed and thorough
        - Legally informed and compliant
  
      - Important: Avoid special characters like ``` or ###. Do not include redundant headings. Ensure the letter is clear, structured, and ready to send.
    PROMPT
  end  

  def bankruptcy_step_1(public_record, bureau)
    <<-PROMPT
      You are tasked with generating a letter to the #{@user.state} bankruptcy court to ask the following information. It is crucial you create the heading with the sender information and the recipient mailing address (find #{@user.state} bankruptcy court address) without including special characters like ``` or ### in the final output.
  
      Requirement: Create a professional, ready-to-send heading with the following details:
      - Name: #{@user.first_name} #{@user.last_name}
      - Street Address: #{@user.street_address}
      - City: #{@user.city}
      - State: #{@user.state}
      - Postal Code: #{@user.postal_code}
      - Country: "USA"
      - SSN Last 4: ###SSN_LAST4### (Include under sender address)
      - Current Date: #{Date.today.strftime("%B %d, %Y")}
  
      Include the recipient's mailing address (find #{@user.state} bankruptcy court address).
  
      Information:
      #{format_public_records_by_bureau(public_record, bureau)}
  
      Content of the Letter:
      - Introduction: State the purpose of the letter.
      - Questions: List the specific questions regarding the reporting of bankruptcy information.
      - Conclusion: Request for clarification and further instructions if needed.
  
      Example Structure:
      [Your Name]
      [Your Street Address]
      [City, State, Postal Code]
      USA
      SSN Last 4: [Your SSN Last 4]
      [Current Date]
  
      [Recipient's Name]
      [Recipient's Title]
      [Bankruptcy Court Name]
      [Street Address]
      [City, State, Postal Code]
  
      Dear [Recipient's Name],
  
      I am writing to inquire about the reporting procedures of bankruptcy information from your court. It has come to my attention that this bankruptcy is being reported to LexisNexis and various credit bureaus. As the debtor, I would like to confirm whether your court reports bankruptcy information to LexisNexis and the credit bureaus directly.
  
      Please provide clarification on the following questions:
      
      1. Does the court report bankruptcy filings directly to LexisNexis?
      2. Does the court report bankruptcy filings directly to the credit bureaus?
      3. If the court does not report this information, could you please inform me how LexisNexis and the credit bureaus might be obtaining the bankruptcy details?
  
      Thank you for your assistance in this matter.
  
      Sincerely,
      [Your Name]
  
      Tone and Style:
      - Professional and assertive
      - Clear and concise
  
      Important: Do not include special characters like ``` or ###. Ensure the letter is clear, structured, and ready to send.
    PROMPT
  end
  

  def bankruptcy_step_2(public_record, bureau)
    <<-PROMPT
      You are tasked with generating a letter to LexisNexis dispute center to remove the following information from my report. It is crucial you create the heading with the sender information and the recipient mailing address (LexisNexis Dispute address) without including special characters like ``` or ### in the final output.
  
      Requirement: Create a professional, ready-to-send heading with the following details:
      - Name: #{@user.first_name} #{@user.last_name}
      - Street Address: #{@user.street_address}
      - City: #{@user.city}
      - State: #{@user.state}
      - Postal Code: #{@user.postal_code}
      - Country: "USA"
      - SSN Last 4: ###SSN_LAST4###
      - Current Date: #{Date.today.strftime("%B %d, %Y")}
  
      Include the recipient's mailing address (LexisNexis Dispute address).
  
      Information:
      #{format_public_records_by_bureau(public_record, bureau)}
  
      Content of the Letter:
      - Introduction: State the purpose of the letter.
      - Explanation: Explain the situation and the information received from the US Bankruptcy Court.
      - Request: Formally request the removal of inaccurate information in accordance with the Fair Credit Reporting Act (FCRA).
      - Conclusion: Request written confirmation of the removal.
  
      Example Structure:
      [Your Name]
      [Your Street Address]
      [City, State, Postal Code]
      USA
      SSN Last 4: [Your SSN Last 4]
      [Current Date]
  
      LexisNexis Dispute Center
      [Street Address]
      [City, State, Postal Code]
  
      Dear Sir/Madam,
  
      I have received a letter from the US Bankruptcy Court confirming that they do not report bankruptcy information to LexisNexis or any other consumer reporting agency. As such, you cannot verify that the bankruptcy information you have on file is accurate or belongs to me.
  
      In accordance with the Fair Credit Reporting Act (FCRA), I am formally requesting that LexisNexis remove this inaccurate bankruptcy information from my report immediately. Please provide me with written confirmation of the removal.
  
      Thank you for your assistance in this matter.
  
      Sincerely,
      [Your Name]
  
      Tone and Style:
      - Professional and assertive
      - Clear and concise
  
      Important: Do not include special characters like ``` or ###. Ensure the letter is clear, structured, and ready to send.
    PROMPT
  end  

  def format_inquiries(inquiries, bureau, limit = 5)
    inquiries.select { |inquiry| inquiry[:bureau].downcase == bureau.downcase }
             .first(limit)
             .map { |inquiry| "- Name: #{inquiry[:name]}, Bureau: #{inquiry[:bureau].capitalize} is an unconfirmed inquiry, not as of yet proven to be with the
             necessary adequate and required achieved lawful Permissible Purpose, and or is not certifiably compliant as it is currently reported.
             Please ERADICATE from reporting promptly" }
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

  def format_public_records_by_bureau(records, bureau)
    public_records = records.select do |record|
      record[:bureau_details].any? { |detail| detail[:bureau].downcase == bureau.downcase }
    end

    public_records.each do |account|
      details = account[:bureau_details].find { |detail| detail[:bureau].downcase == bureau.downcase }
      <<-DETAILS
        Public Information
        status: #{account[:status]}
        Dated Filed Report: #{account[:date_filed_reported]}
        Closing Date: #{account[:closing_date]}
        Asset Amount: #{details[:asset_amount] || '-'}
        Court: #{details[:court] || '-'}
        liability: #{details[:liability] || '-'}
      DETAILS
    end.join("\n\n")
  end

  def inject_sensitive_data(letter_text, ssn_last4)
    placeholder = "###SSN_LAST4###"
    letter_text.gsub(placeholder, ssn_last4)
  end
end