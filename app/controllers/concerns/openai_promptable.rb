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
    prompt = get_prompt(round, inquiries, accounts, bureau)
    response = @client.chat(
      parameters: {
        model: "gpt-4o",
        messages: [
          { role: "system", content: "You are an AI that generates Metro 2 compliance dispute letters for credit inquiries and accounts." },
          { role: "user", content: prompt }
        ],
        max_tokens: 1000
      }
    )
    response['choices'].first['message']['content']
  end

  def get_prompt(round, inquiries, accounts, bureau)
    case round
    when 1 then round_1_prompt(inquiries, accounts, bureau)
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

  def round_1_prompt(inquiries, accounts, bureau)
    <<-PROMPT
      You are a credit repair expert using Metro 2 compliance standards so please use metro 2 codes in the letter. Draft a detailed dispute letter to the #{bureau.capitalize} regarding the inquiries below. Highlight the inaccuracies in the inquiry and request its immediate removal, citing relevant Metro 2 compliance regulations. The letter should be professional, concise, and emphasize the need for accurate reporting

      user info for address: 
      first_name: #{current_user.first_name}
      last_name: #{current_user.last_name}
      street_address: #{current_user.street_address}
      city: #{current_user.city}
      state: #{current_user.state}
      postal_code: #{current_user.postal_code}
      country: #{current_user.country}
      current_date: #{Date.today.strftime("%B %d, %Y")}

      Inquiries:
      #{format_inquiries(inquiries, bureau)}

      Use metro 2 codes for the accounts below to dispute the complaince. Highlight the inaccuracies in the account information and request its immediate removal, citing relevant Metro 2 compliance regulations. The letter should be professional, concise, and emphasize the need for accurate reporting. Be sure to use FCRA as well

      Accounts:
      #{format_accounts(accounts, bureau)}

      Please only user the name and address in the header. Nothing else is to be added
    PROMPT
  end

  def round_2_prompt(inquiries, accounts, bureau)
    <<-PROMPT
      This is a round 2 Metro 2 compliance dispute letter for the #{bureau.capitalize} bureau. We have the following inquiries and accounts that need to be disputed.

      Inquiries:
      #{format_inquiries(inquiries, bureau)}

      Accounts:
      #{format_accounts(accounts, bureau)}

      Please ensure the credit bureaus remove any inaccurate information immediately and use Metro 2 compliance and FCRA.
    PROMPT
  end

  def round_3_prompt(inquiries, accounts, bureau)
    <<-PROMPT
      This is a round 3 Metro 2 compliance dispute letter for the #{bureau.capitalize} bureau. We have the following inquiries and accounts that need to be disputed.

      Inquiries:
      #{format_inquiries(inquiries, bureau)}

      Accounts:
      #{format_accounts(accounts, bureau)}

      Please ensure the credit bureaus remove any inaccurate information immediately and use Metro 2 compliance and FCRA.
    PROMPT
  end

  def round_4_prompt(inquiries, accounts, bureau)
    <<-PROMPT
      This is a round 4 Metro 2 compliance dispute letter for the #{bureau.capitalize} bureau. We have the following inquiries and accounts that need to be disputed.

      Inquiries:
      #{format_inquiries(inquiries, bureau)}

      Accounts:
      #{format_accounts(accounts, bureau)}

      Please ensure the credit bureaus remove any inaccurate information immediately and use Metro 2 compliance and FCRA.
    PROMPT
  end

  def round_5_prompt(inquiries, accounts, bureau)
    <<-PROMPT
      This is a round 5 Metro 2 compliance dispute letter for the #{bureau.capitalize} bureau. We have the following inquiries and accounts that need to be disputed.

      Inquiries:
      #{format_inquiries(inquiries, bureau)}

      Accounts:
      #{format_accounts(accounts, bureau)}

      Please ensure the credit bureaus remove any inaccurate information immediately and use Metro 2 compliance and FCRA.
    PROMPT
  end

  def round_6_prompt(inquiries, accounts, bureau)
    <<-PROMPT
      This is a round 6 Metro 2 compliance dispute letter for the #{bureau.capitalize} bureau. We have the following inquiries and accounts that need to be disputed.

      Inquiries:
      #{format_inquiries(inquiries, bureau)}

      Accounts:
      #{format_accounts(accounts, bureau)}

      Please ensure the credit bureaus remove any inaccurate information immediately and use Metro 2 compliance and FCRA.
    PROMPT
  end

  def round_7_prompt(inquiries, accounts, bureau)
    <<-PROMPT
      This is a round 7 Metro 2 compliance dispute letter for the #{bureau.capitalize} bureau. We have the following inquiries and accounts that need to be disputed.

      Inquiries:
      #{format_inquiries(inquiries, bureau)}

      Accounts:
      #{format_accounts(accounts, bureau)}

      Please ensure the credit bureaus remove any inaccurate information immediately and use Metro 2 compliance and FCRA.
    PROMPT
  end

  def format_inquiries(inquiries, bureau)
    inquiries.select { |inquiry| inquiry[:bureau].downcase == bureau.downcase }
             .map { |inquiry| "- Name: #{inquiry[:name]}, Bureau: #{inquiry[:bureau].capitalize}" }
             .join("\n")
  end

  def format_accounts(accounts, bureau)
    accounts.select { |account| account[:bureau].include?(bureau.downcase) }
            .map { |account| "- Account Number: #{account[:number]}, Bureau: #{bureau.capitalize}" }
            .join("\n")
  end
end
