class FetchCreditReportJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: 2

  def perform(username, password, security_question, service, user_id, browser, user_agent, user_agent_request)
    user = User.find(user_id)
    user_browser = browser
    user_agent_request = user_agent_request
    mobile = user_agent.include?("Mobile") || user_agent.include?("iPhone")

    case service
    when 'identityiq'
      idq = IdentityiqService.new(user_agent_request, username, password, security_question, browser: :chrome, mobile: mobile)
      json_content = idq.fetch_credit_report

      if json_content.is_a?(String) && json_content == "Wrong username or password"
        notify_user(user, json_content)
        return
      end

      import_credit_report_json(user, json_content, username, password, security_question, service)
    when 'smartcredit'
      driver = SmartCreditService.new(user_agent_request, username, password, user, browser: user_browser, mobile: mobile)
      json_content = driver.fetch_credit_report

      if json_content.is_a?(String) && json_content == "Wrong username or password"
        notify_user(user, json_content)
        return
      end

      import_credit_report_json(user, json_content, username, password, security_question, service)
    else
      notify_user(user, 'Invalid service selected.')
      return
    end
  end

  private

  def import_credit_report_json(user, json, username, password, security_question, service)
    if json
      document_io = StringIO.new(json)
      document_io.class.class_eval { attr_accessor :original_filename, :content_type }
      document_io.original_filename = 'credit_report.json'
      document_io.content_type = 'application/json'

      credit_report = user.credit_reports.build(
        username: username,
        password: password,
        security_question: security_question,
        service: service
      )
      credit_report.document.attach(io: document_io, filename: document_io.original_filename, content_type: document_io.content_type)
      credit_report.extract_scores(json) if service == "identityiq"
      credit_report.extract_and_save_smart_credit_scores(json) if service == "smartcredit"

      if credit_report.save
        parse_credit_report(credit_report, user) if service == "identityiq"
        notify_user(user, 'Credit report successfully imported and parsed.')
      else
        notify_user(user, 'Failed to save the credit report.')
      end
    else
      notify_user(user, 'Failed to import credit report.')
    end
  end

  def parse_credit_report(credit_report, user)
    document_content = credit_report.document.download

    parser = IdentityiqParserService.new(document_content)

    content = parser.extract_content
    process_parsed_content(content, credit_report, user)
  end

  def process_parsed_content(content, credit_report, user)
    inquiries = content[:inquiries]
    accounts = content[:accounts]

    ActiveRecord::Base.transaction do
      ActiveRecord::Base.connection.execute("DELETE FROM inquiries WHERE user_id = #{user.id}")
      BureauDetail.where(account_id: user.accounts.pluck(:id)).delete_all
      ActiveRecord::Base.connection.execute("DELETE FROM accounts WHERE user_id = #{user.id}")
      BureauDetail.where(public_record_id: user.public_records.pluck(:id)).delete_all
      ActiveRecord::Base.connection.execute("DELETE FROM public_records WHERE user_id = #{user.id}")
    end 
    
    inquiries.each do |inquiry_attrs|
      inquiry_attrs[:user] = user
      Inquiry.create!(inquiry_attrs)
    end

    accounts.each do |account_attrs|
      next if account_attrs[:account_number].nil?

      account = Account.find_or_create_by!(
        account_number: account_attrs[:account_number],
        user_id: user.id
      ) do |acc|
        acc.account_type = account_attrs[:account_type]
        acc.account_status = account_attrs[:account_status]
        acc.name = account_attrs[:name]
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
          date_of_last_payment: details[:date_of_last_payment]
        )
      end
    end
  end

  def notify_user(user, message)
    UserMailer.notification_email(user, message).deliver_later
  end
end
