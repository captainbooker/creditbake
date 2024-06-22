module ImportCreditReports
  extend ActiveSupport::Concern

  def import
    user_browser = detect_browser(request.user_agent)

    service = params[:service]
    username = params[:username]
    password = params[:password]
    security_question = params[:security_question]

    case service
    when 'identityiq'
      idq = IdentityiqService.new(username, password, security_question, browser: user_browser, mobile: request.user_agent.include?("Mobile") || request.user_agent.include?("iPhone"))
      json_content = idq.fetch_credit_report
      import_credit_report_json(json_content, username, password, security_question, service)
    when 'smartcredit'
      driver = SmartCreditService.new(username, password, current_user, browser: user_browser, mobile: request.user_agent.include?("Mobile") || request.user_agent.include?("iPhone"))
      json_content = driver.fetch_credit_report
      import_credit_report_json(json_content, username, password, security_question, service)
    else
      redirect_to new_credit_report_path, alert: 'Invalid service selected.'
    end
  end

  private

  def import_credit_report_json(json, username, password, security_question, service)
    if json
      document_io = StringIO.new(json)
      document_io.class.class_eval { attr_accessor :original_filename, :content_type }
      document_io.original_filename = 'credit_report.json'
      document_io.content_type = 'application/json'

      @credit_report = current_user.credit_reports.build(
        username: username,
        password: password,
        security_question: security_question,
        service: service
      )
      @credit_report.document.attach(io: document_io, filename: document_io.original_filename, content_type: document_io.content_type)
      @credit_report.extract_scores(json) if service == "identityiq"

      if @credit_report.save
        parse_credit_report(@credit_report)  if service == "identityiq"
        redirect_to challenge_path, notice: 'Credit report successfully imported and parsed.'
      else
        redirect_to new_credit_report_path, alert: 'Failed to save the credit report.'
      end
    else
      redirect_to new_credit_report_path, alert: 'Failed to import credit report.'
    end
  end
end
