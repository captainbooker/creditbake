# app/controllers/concerns/openai_promptable.rb
module OpenaiPromptable
  extend ActiveSupport::Concern

  included do
    before_action :initialize_openai_client
  end

  def send_prompts_for_round(round, inquiries, accounts)
    {
      experian: send_prompt(round, inquiries, accounts, 'experian'),
      transunion: send_prompt(round, inquiries, accounts, 'transunion'),
      equifax: send_prompt(round, inquiries, accounts, 'equifax')
    }
  end

  private

  def initialize_openai_client
    @client = OpenAI::Client.new(access_token: ENV['OPENAI_ACCESS_TOKEN'])
  end

  def send_prompt(round, inquiries, accounts, bureau)
    formatted_table = format_accounts_with_bureau_details(accounts)
  
    prompt = get_prompt(round, inquiries, accounts, bureau, formatted_table)
    response = @client.chat(
      parameters: {
        model: "gpt-4",
        messages: [
          { role: "system", content: "You are an AI that generates Metro 2 compliance dispute letters for credit inquiries and accounts." },
          { role: "user", content: prompt }
        ],
        max_tokens: 1000
      }
    )
    response_text = response['choices'].first['message']['content']
    inject_sensitive_data(response_text, current_user.ssn_last4)
  end
  

  def get_prompt(round, inquiries, accounts, bureau, formatted_table)
    case round
    when 1 then round_1_prompt(inquiries, accounts, bureau, formatted_table)
    when 2 then round_2_prompt(inquiries, accounts, bureau)
    when 3 then round_3_prompt(inquiries, accounts, bureau)
    when 4 then round_4_prompt(inquiries, accounts, bureau)
    when 5 then round_5_prompt(inquiries, accounts, bureau)
    when 6 then round_6_prompt(inquiries, accounts, bureau)
    when 7 then round_7_prompt(inquiries, accounts, bureau)
    else
      "Invalid round selected."
    end
  end

  def round_1_prompt(inquiries, accounts, bureau, formatted_table)
    <<-PROMPT
      You are a credit repair expert using Metro 2 compliance standards, so please use Metro 2 codes in the letter. Draft a detailed dispute letter to the #{bureau.capitalize} regarding the inquiries below. Highlight the inaccuracies in the inquiry and request its immediate removal, citing relevant Metro 2 compliance regulations. The letter should be professional, concise, and emphasize the need for accurate reporting.
  
      User info for address:
      first_name: #{current_user.first_name}
      last_name: #{current_user.last_name}
      street_address: #{current_user.street_address}
      city: #{current_user.city}
      state: #{current_user.state}
      postal_code: #{current_user.postal_code}
      country: "USA"
      SSN Last 4: ###SSN_LAST4### (Include under sender address)
      current_date: #{Date.today.strftime("%B %d, %Y")}
  
      Inquiries:
      #{format_inquiries(inquiries, bureau)}
  
      Use Metro 2 codes for the accounts below to dispute the compliance. Highlight the inaccuracies in the account information and request its immediate removal, citing relevant Metro 2 compliance regulations. The letter should be professional, concise, and emphasize the need for accurate reporting. Be sure to use FCRA as well and I should only be contacted at the address provided.
  
      Accounts: (I am providing you with a table of data with headers, table_separator & table_rows. Take all the data and put it in a table)
      #{formatted_table}
    PROMPT
  end

  def round_2_prompt(inquiries, accounts, bureau)
    <<-PROMPT
    You are a credit repair expert using Metro 2 compliance standards, so please use Metro 2 codes in the letter. Draft a follow-up dispute letter to the #{bureau.capitalize} regarding the inquiries and accounts provided. Reference the previous dispute letter sent and emphasize the lack of response or correction. Reiterate the inaccuracies and request immediate removal, citing relevant Metro 2 compliance regulations and potential consequences of non-compliance.

      User info for address:
      first_name: #{current_user.first_name}
      last_name: #{current_user.last_name}
      street_address: #{current_user.street_address}
      city: #{current_user.city}
      state: #{current_user.state}
      postal_code: #{current_user.postal_code}
      country: USA
      SSN Last 4: ###SSN_LAST4### (Include under sender address)
      current_date: #{Date.today.strftime("%B %d, %Y")}

      Inquiries:
      #{format_inquiries(inquiries, bureau)}

      Accounts:
      #{format_accounts(accounts, bureau)}

      Please ensure the credit bureaus remove any inaccurate information immediately and use Metro 2 compliance and FCRA and I should only be contacted at the address provided.
    PROMPT
  end

  def round_3_prompt(inquiries, accounts, bureau)
    <<-PROMPT
      This is a Metro 2 compliance dispute letter, so please use Metro 2 codes in the letter followed by previous challnege letters for the #{bureau.capitalize} bureau. We have the following inquiries and accounts that need to be disputed using metro 2 and FCRA. The credit bureau has failed to investigate/comply to remove inquiries and accounts per FCRA.

      User info for address:
      first_name: #{current_user.first_name}
      last_name: #{current_user.last_name}
      street_address: #{current_user.street_address}
      city: #{current_user.city}
      state: #{current_user.state}
      postal_code: #{current_user.postal_code}
      country: USA
      SSN Last 4: ###SSN_LAST4### (Include under sender address)
      current_date: #{Date.today.strftime("%B %d, %Y")}

      Inquiries:
      #{format_inquiries(inquiries, bureau)}

      Accounts:
      #{format_accounts(accounts, bureau)}

      Please ensure the credit bureaus remove any inaccurate information immediately and use Metro 2 compliance and FCRA and I should only be contacted at the address provided.
    PROMPT
  end

  def round_4_prompt(inquiries, accounts, bureau)
    <<-PROMPT
    You are a credit repair expert using Metro 2 compliance standards, so please use Metro 2 codes in the letter. Draft a detailed dispute letter to the #{bureau.capitalize} regarding the inquiries and accounts provided. Request that they reinvestigate and comply with metro 2 and fcra. Be unique with letter and threaten to complain and file a law suit if accounts and inquires are not removed. Include detailed evidence and documentation supporting the inaccuracies. Emphasize the importance of compliance with Metro 2 regulations and request immediate removal of the inaccurate inquiry

      User info for address:
      first_name: #{current_user.first_name}
      last_name: #{current_user.last_name}
      street_address: #{current_user.street_address}
      city: #{current_user.city}
      state: #{current_user.state}
      postal_code: #{current_user.postal_code}
      country: USA
      SSN Last 4: ###SSN_LAST4### (Include under sender address)
      current_date: #{Date.today.strftime("%B %d, %Y")}

      Inquiries:
      #{format_inquiries(inquiries, bureau)}

      Accounts:
      #{format_accounts(accounts, bureau)}

      Please ensure the credit bureaus remove any inaccurate information immediately and use Metro 2 compliance and FCRA and I should only be contacted at the address provided.
    PROMPT
  end

  def round_5_prompt(inquiries, accounts, bureau)
    <<-PROMPT
    You are a credit repair expert using Metro 2 compliance standards, so please use Metro 2 codes in the letter. Draft a strongly worded dispute letter to the #{bureau.capitalize} regarding the inquires and accounts provided. Set a firm deadline for action. State that failure to address the inaccuracies within the specified time frame will result in further action, including complaints to regulatory authorities.

      User info for address:
      first_name: #{current_user.first_name}
      last_name: #{current_user.last_name}
      street_address: #{current_user.street_address}
      city: #{current_user.city}
      state: #{current_user.state}
      postal_code: #{current_user.postal_code}
      country: USA
      SSN Last 4: ###SSN_LAST4### (Include under sender address)
      current_date: #{Date.today.strftime("%B %d, %Y")}

      Inquiries:
      #{format_inquiries(inquiries, bureau)}

      Accounts:
      #{format_accounts(accounts, bureau)}

      Please ensure the credit bureaus remove any inaccurate information immediately and use Metro 2 compliance and FCRA and I should only be contacted at the address provided.
    PROMPT
  end

  def round_6_prompt(inquiries, accounts, bureau)
    <<-PROMPT
    You are a credit repair expert using Metro 2 compliance standards, so please use Metro 2 codes in the letter. Draft a final warning dispute letter to the #{bureau.capitalize} regarding an inquiries and accounts provided. Emphasize that this is the final attempt to resolve the issue amicably. State clearly that failure to correct the inaccuracies will result in legal action and formal complaints to regulatory authorities.

      User info for address:
      first_name: #{current_user.first_name}
      last_name: #{current_user.last_name}
      street_address: #{current_user.street_address}
      city: #{current_user.city}
      state: #{current_user.state}
      postal_code: #{current_user.postal_code}
      country: USA
      SSN Last 4: ###SSN_LAST4### (Include under sender address)
      current_date: #{Date.today.strftime("%B %d, %Y")}

      Inquiries:
      #{format_inquiries(inquiries, bureau)}

      Accounts:
      #{format_accounts(accounts, bureau)}

      Please ensure the credit bureaus remove any inaccurate information immediately and use Metro 2 compliance and FCRA and I should only be contacted at the address provided.
    PROMPT
  end

  def round_7_prompt(inquiries, accounts, bureau)
    <<-PROMPT
    You are a credit repair expert using Metro 2 compliance standards, so please use Metro 2 codes in the letter. Draft a letter to the #{bureau.capitalize} regarding an inquiries and accounts provided, initiating legal action and filing formal complaints to regulatory authorities. Reference detail the lack of response or correction. State the legal actions being taken and include copies of the complaints filed with regulatory authorities.

      User info for address:
      first_name: #{current_user.first_name}
      last_name: #{current_user.last_name}
      street_address: #{current_user.street_address}
      city: #{current_user.city}
      state: #{current_user.state}
      postal_code: #{current_user.postal_code}
      country: USA
      SSN Last 4: ###SSN_LAST4### (Include under sender address)
      current_date: #{Date.today.strftime("%B %d, %Y")}

      Inquiries:
      #{format_inquiries(inquiries, bureau)}

      Accounts: (I am proving you with a table of data with headers, table_separator & table_rows. Take all the data and put it in a table)
      #{format_accounts(accounts, bureau)}

      Please ensure the credit bureaus remove any inaccurate information immediately and use Metro 2 compliance and FCRA and I should only be contacted at the address provided.
    PROMPT
  end

  def format_inquiries(inquiries, bureau)
    inquiries.select { |inquiry| inquiry[:bureau].downcase == bureau.downcase }
             .map { |inquiry| "- Name: #{inquiry[:name]}, Bureau: #{inquiry[:bureau].capitalize}" }
             .join("\n")
  end

  def format_accounts_with_bureau_details(accounts)
    table_headers = "| Account Name | Account Number | Experian Balance | TransUnion Balance | Equifax Balance | Experian Status | TransUnion Status | Equifax Status | Date Opened |\n"
    table_separator = "|--------------|----------------|------------------|--------------------|-----------------|----------------|-------------------|----------------|-------------|\n"
  
    table_rows = accounts.map do |account|
      experian_details = account[:bureau_details].find { |detail| detail[:bureau].downcase == 'experian' }
      transunion_details = account[:bureau_details].find { |detail| detail[:bureau].downcase == 'transunion' }
      equifax_details = account[:bureau_details].find { |detail| detail[:bureau].downcase == 'equifax' }
  
      "| #{account[:name]} | #{account[:number]} | #{experian_details&.dig(:balance_owed) || '-'} | #{transunion_details&.dig(:balance_owed) || '-'} | #{equifax_details&.dig(:balance_owed) || '-'} | #{experian_details&.dig(:payment_status) || '-'} | #{transunion_details&.dig(:payment_status) || '-'} | #{equifax_details&.dig(:payment_status) || '-'} | #{experian_details&.dig(:date_opened) || '-'} |"
    end.join("\n")
  
    table_headers + table_separator + table_rows
  end
  
  

  def inject_sensitive_data(letter_text, ssn_last4)
    placeholder = "###SSN_LAST4###"
    letter_text.gsub(placeholder, ssn_last4)
  end
end
