class FetchCreditReportJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: 2

  def perform(username, password, security_question, service, user_id, browser, user_agent, user_agent_request, client_id)
    user = User.find(user_id)
    user_browser = browser
    user_agent_request = user_agent_request
    client = client_id.present? ? Client.find(client_id) : nil
    mobile = user_agent.include?("Mobile") || user_agent.include?("iPhone")

    case service
    when 'identityiq'
      idq = IdentityiqService.new(user_agent_request, username, password, security_question, browser: :chrome, mobile: mobile)
      json_content = idq.fetch_credit_report

      if json_content.is_a?(String) && json_content == "Wrong username or password"
        notify_user(user, json_content)
        return
      end

      import_credit_report_json(user, json_content, username, password, security_question, service, client)
    when 'smartcredit'
      driver = SmartCreditService.new(client, user_agent_request, username, password, user, browser: user_browser, mobile: mobile)
      json_content = driver.fetch_credit_report

      if json_content.is_a?(String) && json_content == "Wrong username or password"
        notify_user(user, json_content)
        return
      end

      import_credit_report_json(user, json_content, username, password, security_question, service, client)
    else
      notify_user(user, 'Invalid service selected.')
      return
    end
  end

  private

  def import_credit_report_json(user, json, username, password, security_question, service, client)
    if json
      document_io = StringIO.new(json)
      document_io.class.class_eval { attr_accessor :original_filename, :content_type }
      document_io.original_filename = 'credit_report.json'
      document_io.content_type = 'application/json'

      if client.present?
        credit_report = client.credit_reports.build(
          username: username,
          password: password,
          security_question: security_question,
          service: service
        )
      else
        credit_report = user.credit_reports.build(
          username: username,
          password: password,
          security_question: security_question,
          service: service
        )
      end
      credit_report.document.attach(io: document_io, filename: document_io.original_filename, content_type: document_io.content_type)
      credit_report.extract_scores(json) if service == "identityiq"
      credit_report.extract_and_save_smart_credit_scores(json) if service == "smartcredit"

      if credit_report.save
        parse_credit_report(credit_report, user, client) if service == "identityiq"
        notify_user(user, 'Credit report successfully imported and parsed.')
      else
        notify_user(user, 'Failed to save the credit report.')
      end
    else
      notify_user(user, 'Failed to import credit report.')
    end
  end

  def parse_credit_report(credit_report, user, client)
    document_content = credit_report.document.download

    parser = IdentityiqParserService.new(document_content)

    content = parser.extract_content
    process_parsed_content(content, credit_report, user, client)
  end

  def process_parsed_content(content, credit_report, user, client)
    inquiries = content[:inquiries]
    accounts = content[:accounts]
    personal_information = content[:personal_information]

    if client.present?
      client.inquiries.delete_all
      BureauDetail.where(account_id: client.accounts.pluck(:id)).delete_all
      client.accounts.delete_all
      BureauDetail.where(public_record_id: client.public_records.pluck(:id)).delete_all
      client.public_records.delete_all
      client.personal_informations.delete_all

      inquiry_creation(inquiries, client)
      account_creation(accounts, client)
      personal_information_creation(personal_information, client)
    else
      user.inquiries.delete_all
      BureauDetail.where(account_id: user.accounts.pluck(:id)).delete_all
      user.accounts.delete_all
      BureauDetail.where(public_record_id: user.public_records.pluck(:id)).delete_all
      user.public_records.delete_all
      user.personal_informations.delete_all

      inquiry_creation(inquiries, user)
      account_creation(accounts, user)
      personal_information_creation(personal_information, user)
    end
  end

  def inquiry_creation(inquiries, type)
    inquiries.each do |inquiry_attrs|
      if type.is_a?(Client)
        inquiry_attrs[:client] = type
      else
        inquiry_attrs[:user] = type
      end
      Inquiry.create!(inquiry_attrs)
    end
  end

  def account_creation(accounts, type)
    accounts.each do |account_attrs|
      next if account_attrs[:account_number].nil?
      
      if type.is_a?(Client)
        account = Account.find_or_create_by!(
          account_number: account_attrs[:account_number],
          client_id: type.id
        ) do |acc|
          acc.account_type = account_attrs[:account_type]
          acc.account_status = account_attrs[:account_status]
          acc.name = account_attrs[:name]
        end
      else
        account = Account.find_or_create_by!(
          account_number: account_attrs[:account_number],
          user_id: type.id
        ) do |acc|
          acc.account_type = account_attrs[:account_type]
          acc.account_status = account_attrs[:account_status]
          acc.name = account_attrs[:name]
        end
      end

      account_attrs[:bureau_details].each do |bureau, details|
        next unless [:transunion, :experian, :equifax].include?(bureau)

        BureauDetail.create!(
          account: account,
          bureau: bureau,
          balance_owed: details[:high_balance],
          high_credit: details[:high_credit],
          credit_limit: details[:credit_limit],
          past_due_amount: details[:past_due_amount],
          payment_status: details[:payment_status],
          date_opened: details[:date_opened],
          date_of_last_payment: details[:date_of_last_payment],
          comment: details[:comment],
          monthly_payment: details[:monthly_payment]
        )
      end
    end
  end

  def personal_information_creation(personal_information, type)
    if type.is_a?(Client)
      personal_information.each do |key, infos|
        infos.group_by { |info| info[:bureau] }.each do |bureau, details|
          PersonalInformation.create!(
            client: type,
            bureau: bureau,
            name: details.select { |d| d[:type] == 'Primary' }.map { |d| "#{d[:first]} #{d[:middle]} #{d[:last]}" }.join(', '),
            date_of_birth: details.select { |d| d[:date] }.map { |d| "#{d[:date]}-#{d[:month]}-#{d[:day]}" }.first,
            current_addresses: details.select { |d| d[:street] && d[:address_order] == "0" }.map { |d| "#{d[:street]}, #{d[:city]}, #{d[:state]} #{d[:postal_code]}" }.join(', '),
            previous_addresses: details.select { |d| d[:street] && d[:address_order] != "0" }.map { |d| "#{d[:street]}, #{d[:city]}, #{d[:state]} #{d[:postal_code]}" }.join(', '),
            employers: details.select { |d| d[:name] }.map { |d| "#{d[:name]}, Reported: #{d[:date_reported]}, Updated: #{d[:date_updated]}" }.join(', ')
          )
        end
      end
    else
      personal_information.each do |key, infos|
        infos.group_by { |info| info[:bureau] }.each do |bureau, details|
          PersonalInformation.create!(
            user: type,
            bureau: bureau,
            name: details.select { |d| d[:type] == 'Primary' }.map { |d| "#{d[:first]} #{d[:middle]} #{d[:last]}" }.join(', '),
            date_of_birth: details.select { |d| d[:date] }.map { |d| "#{d[:date]}-#{d[:month]}-#{d[:day]}" }.first,
            current_addresses: details.select { |d| d[:street] && d[:address_order] == "0" }.map { |d| "#{d[:street]}, #{d[:city]}, #{d[:state]} #{d[:postal_code]}" }.join(', '),
            previous_addresses: details.select { |d| d[:street] && d[:address_order] != "0" }.map { |d| "#{d[:street]}, #{d[:city]}, #{d[:state]} #{d[:postal_code]}" }.join(', '),
            employers: details.select { |d| d[:name] }.map { |d| "#{d[:name]}, Reported: #{d[:date_reported]}, Updated: #{d[:date_updated]}" }.join(', ')
          )
        end
      end
    end
  end

  def notify_user(user, message)
    UserMailer.notification_email(user, message).deliver_later
  end
end
