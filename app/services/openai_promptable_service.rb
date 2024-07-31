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
          { role: "system", content: "Your task is to summarize metro 2 compliance and CDIA standards and coordinate that with FCRA. Your response should be at least 8 paragraphs." },
          { role: "user", content: prompt }
        ],
        max_tokens: 4096
      }
    )
    response_text = response['choices'].first['message']['content']
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
    Ensure the final output does not include special characters like ``` or ###.

    - Requirements:
      - Generate a unique, Inquiry removal summary
      - Summarize my rights(consumer) under relevant laws.
      - Cite relevant laws and Metro 2 codes for support.
      - Request for investigation in compliance per CDIA and Metro 2 compliance, FCRA 
      - Emphasize the urgency and importance of resolving the dispute.

    - Additional Requirements:
      - Include relevant legal references, such as the CDIA and Metro 2 Compliance and other pertinent federal or state laws.
      - Maintain a professional, assertive, and clear tone, emphasizing the consumer's legal rights.
      - Reference any necessary supporting documentation, though actual documents are not provided.
  

    - Tone and Style:
      - Professional and assertive
      - Detailed and thorough
      - Legally informed and compliant

    - Important: Avoid special characters like ``` or ### and complimentary close.

    PROMPT
  end

  def account_validation(inquiries, accounts, public_record, bureau)
    <<-PROMPT
      Generate a unique, comprehensive Metro 2 account validation summary. Ensure the final output does not include special characters like ``` or ###.
  
      - Additional Requirements:
        - Include relevant legal references, such as the CDIA and Metro 2 Compliance and other pertinent federal or state laws.
        - Maintain a professional, assertive, and clear tone, emphasizing the consumer's legal rights.
        - Reference any necessary supporting documentation, though actual documents are not provided.
  
      - Structure:
        - **Consumer Rights Overview**: Summarize my rights(consumer) under relevant laws.
        - **Legal References**: Cite relevant laws and Metro 2 codes for support.
        - **Request for Action**: Request for investigation in compliance per CDIA and Metro 2 compliance, FCRA 
        - **Demand Results**: Emphasize the urgency and importance of resolving the dispute.
  
      - Tone and Style:
        - Professional and assertive
        - Detailed and thorough
        - Legally informed and compliant

      - Important: Avoid special characters like ``` or ###.
    PROMPT
  end
  

  def round_1_prompt(inquiries, accounts, public_record, bureau)
    <<-PROMPT
      Generate a unique, comprehensive, Metro 2 compliant summary. Ensure the final output does not include special characters like ``` or ###.

      - Additional Requirements:
        - Include relevant legal references, such as the CDIA and Metro 2 Compliance and other pertinent federal or state laws.
        - Maintain a professional, assertive, and clear tone, emphasizing the consumer's legal rights.
        - Reference any necessary supporting documentation, though actual documents are not provided.
  
      - Structure:
        - **Consumer Rights Overview**: Summarize my rights(consumer) under relevant laws.
        - **Legal References**: Cite relevant laws and Metro 2 codes for support.
        - **Request for Action**: Request for investigation in compliance per CDIA and Metro 2 compliance, FCRA 
        - **Demand Results**: Emphasize the urgency and importance of resolving the dispute.
  
      - Tone and Style:
        - Professional and assertive
        - Detailed and thorough
        - Legally informed and compliant

      - Important: Avoid special characters like ``` or ###.
    PROMPT
  end


  def round_2_prompt(inquiries, accounts, public_record, bureau)
    <<-PROMPT
      Generate a unique, comprehensive Metro 2 reinvestigation summary. Ensure the final output does not include special characters like ``` or ###.
  
      - Additional Requirements:
        - Include relevant legal references, such as the CDIA and Metro 2 Compliance and other pertinent federal or state laws.
        - Maintain a professional, assertive, and clear tone, emphasizing the consumer's legal rights.
        - Reference any necessary supporting documentation, though actual documents are not provided.
  
      - Structure:
        - 
        - **Consumer Rights Overview**: Summarize my rights(consumer) under relevant laws.
        - **Legal References**: Cite relevant laws and Metro 2 codes for support.
        - **Request for Action**: Request for investigation in compliance per CDIA and Metro 2 compliance, FCRA 
        - **Demand Results**: Emphasize the urgency and importance of resolving the dispute.
  
      - Tone and Style:
        - Professional and assertive
        - Detailed and thorough
        - Legally informed and compliant

      - Important: Avoid special characters like ``` or ###.
    PROMPT
  end
  

  def round_3_prompt(inquiries, accounts, public_record, bureau)
    <<-PROMPT
      Generate a comprehensive Metro 2 compliance review summary. The final output must not include special characters like ``` or ###.
  
      - Additional Requirements:
        - Include relevant legal references, such as the CDIA and Metro 2 Compliance and other pertinent federal or state laws.
        - Maintain a professional, assertive, and clear tone, emphasizing the consumer's legal rights.
        - Reference any necessary supporting documentation, though actual documents are not provided.
  
      - Structure:
        - **Consumer Rights Overview**: Summarize my rights(consumer) under relevant laws.
        - **Legal References**: Cite relevant laws and Metro 2 codes for support.
        - **Request for Action**: Request for investigation in compliance per CDIA and Metro 2 compliance, FCRA 
        - **Demand Results**: Emphasize the urgency and importance of resolving the dispute.
  
      - Tone and Style:
        - Professional and assertive
        - Detailed and thorough
        - Legally informed and compliant

      - Important: Avoid special characters like ``` or ###.
    PROMPT
  end
  

  def round_4_prompt(inquiries, accounts, public_record, bureau)
    <<-PROMPT
      Generate a comprehensive Metro 2 dispute escalation summary. The final output must not include special characters like ``` or ###.

      - Additional Requirements:
        - Include relevant legal references, such as the CDIA and Metro 2 Compliance and other pertinent federal or state laws.
        - Maintain a professional, assertive, and clear tone, emphasizing the consumer's legal rights.
        - Reference any necessary supporting documentation, though actual documents are not provided.
  
      - Structure:
        - **Consumer Rights Overview**: Summarize my rights(consumer) under relevant laws.
        - **Legal References**: Cite relevant laws and Metro 2 codes for support.
        - **Request for Action**: Request for investigation in compliance per CDIA and Metro 2 compliance, FCRA 
        - **Demand Results**: Emphasize the urgency and importance of resolving the dispute.
  
      - Tone and Style:
        - Professional and assertive
        - Detailed and thorough
        - Legally informed and compliant

      - Important: Avoid special characters like ``` or ###.
    PROMPT
  end  

  def round_5_prompt(inquiries, accounts, public_record, bureau)
    <<-PROMPT
      Generate a comprehensive Metro 2 data reconciliation summary. Ensure the final output does not include special characters like ``` or ###.
  
      - Additional Requirements:
        - Include relevant legal references, such as the CDIA and Metro 2 Compliance and other pertinent federal or state laws.
        - Maintain a professional, assertive, and clear tone, emphasizing the consumer's legal rights.
        - Reference any necessary supporting documentation, though actual documents are not provided.
  
      - Structure:
        - **Consumer Rights Overview**: Summarize my rights(consumer) under relevant laws.
        - **Legal References**: Cite relevant laws and Metro 2 codes for support.
        - **Request for Action**: Request for investigation in compliance per CDIA and Metro 2 compliance, FCRA 
        - **Demand Results**: Emphasize the urgency and importance of resolving the dispute.
  
      - Tone and Style:
        - Professional and assertive
        - Detailed and thorough
        - Legally informed and compliant

      - Important: Avoid special characters like ``` or ###.
    PROMPT
  end  

  def round_6_prompt(inquiries, accounts, public_record, bureau)
    <<-PROMPT
      Generate a comprehensive Metro 2 dispute resolution demand summary. The final output must not include special characters like ``` or ###.

      - Additional Requirements:
        - Include relevant legal references, such as the CDIA and Metro 2 Compliance and other pertinent federal or state laws.
        - Maintain a professional, assertive, and clear tone, emphasizing the consumer's legal rights.
        - Reference any necessary supporting documentation, though actual documents are not provided.
  
      - Structure:
        - **Consumer Rights Overview**: Summarize my rights(consumer) under relevant laws.
        - **Legal References**: Cite relevant laws and Metro 2 codes for support.
        - **Request for Action**: Request for investigation in compliance per CDIA and Metro 2 compliance, FCRA 
        - **Demand Results**: Emphasize the urgency and importance of resolving the dispute.
  
      - Tone and Style:
        - Professional and assertive
        - Detailed and thorough
        - Legally informed and compliant

      - Important: Avoid special characters like ``` or ###.
    PROMPT
  end  

  def round_7_prompt(inquiries, accounts, public_record, bureau)
    <<-PROMPT
      You are tasked with generating a comprehensive Metro 2 compliance and accuracy verification summary. Ensure that the final output does not include special characters like ``` or ###.
  
      - Additional Requirements:
        - Include relevant legal references, such as the CDIA and Metro 2 Compliance and other pertinent federal or state laws.
        - Maintain a professional, assertive, and clear tone, emphasizing the consumer's legal rights.
        - Reference any necessary supporting documentation, though actual documents are not provided.
  
      - Structure:
        - **Consumer Rights Overview**: Summarize my rights(consumer) under relevant laws.
        - **Legal References**: Cite relevant laws and Metro 2 codes for support.
        - **Request for Action**: Request for investigation in compliance per CDIA and Metro 2 compliance, FCRA 
        - **Demand Results**: Emphasize the urgency and importance of resolving the dispute.
  
      - Tone and Style:
        - Professional and assertive
        - Detailed and thorough
        - Legally informed and compliant

      - Important: Avoid special characters like ``` or ###.
    PROMPT
  end  

  def final_demand_prompt(inquiries, accounts, public_record, bureau)
    <<-PROMPT
      You are tasked with generating a comprehensive, summarize a final demand for resolution or threat to go to court. Ensure that the final output does not include special characters like ``` or ###.
  
      - Additional Requirements:
        - Include relevant legal references, such as the CDIA and Metro 2 Compliance and other pertinent federal or state laws.
        - Maintain a professional, assertive, and clear tone, emphasizing the consumer's legal rights.
        - Reference any necessary supporting documentation, though actual documents are not provided.
  
      - Structure:
        - **Consumer Rights Overview**: Summarize my rights(consumer) under relevant laws.
        - **Legal References**: Cite relevant laws and Metro 2 codes for support.
        - **Request for Action**: Request for investigation in compliance per CDIA and Metro 2 compliance, FCRA 
        - **Demand Results**: Emphasize the urgency and importance of resolving the dispute.
  
      - Tone and Style:
        - Professional and assertive
        - Detailed and thorough
        - Legally informed and compliant

      - Important: Avoid special characters like ``` or ###.
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
end