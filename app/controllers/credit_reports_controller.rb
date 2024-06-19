require 'zip'

class CreditReportsController < ApplicationController
  before_action :set_credit_report, only: [:show, :download]

  def new
    @credit_report = CreditReport.new
  end

  def show
  end

  def credit_report
    @user_browser = detect_browser(request.user_agent)
    @credit_reports = current_user.credit_reports
  end

  def create
    @credit_report = current_user.credit_reports.build(credit_report_params)

    if @credit_report.save
      parse_credit_report(@credit_report)
      redirect_to authenticated_root_path, notice: 'Credit report successfully uploaded and parsed.'
    else
      render :new
    end
  end

  def download_all_files
    letter = Letter.find(params[:letter_id])
    files = [letter.experian_pdf, letter.transunion_pdf, letter.equifax_pdf].compact
  
    if files.any?
      zip_data = Zip::OutputStream.write_buffer do |zip|
        files.each do |file|
          zip.put_next_entry(file.filename.to_s)
          zip.write(file.download)
        end
      end
  
      zip_data.rewind
      send_data zip_data.read, filename: "#{letter.name}_challenge_letter_#{Date.today}.zip", type: 'application/zip'
    else
      redirect_back fallback_location: letters_path, alert: 'No files to download'
    end
  end
  
  def import
    user_browser = detect_browser(request.user_agent)

    service = params[:service]
    username = params[:username]
    password = params[:password]
    security_question = params[:security_question]

    case service
    when 'identityiq'
      idq = IdentityiqService.new(username, password, security_question, service, browser: user_browser)
      json_content = idq.fetch_credit_report
      import_credit_report_json(json_content, username, password, security_question, service)
    when 'creditdyno'
      driver = CreditDynoService.login(username, password, security_question, service)
      driver = CreditDynoService.navigate_to_credit_reports(driver)
      html_content = CreditDynoService.get_arr_container_html(driver)
      import_credit_report(html_content, username, password, security_question, service)
    else
      redirect_to new_credit_report_path, alert: 'Invalid service selected.'
    end
  end

  private

  def set_credit_report
    @credit_report = current_user.credit_reports.find(params[:id])
  end

  def credit_report_params
    params.require(:credit_report).permit(:document, :service, :username, :password, :security_question)
  end

  def import_credit_report(html, username, password, security_question, service)
    html_content = html

    if html_content
      document_io = StringIO.new(html_content)
      document_io.class.class_eval { attr_accessor :original_filename, :content_type }
      document_io.original_filename = 'credit_report.html'
      document_io.content_type = 'text/html'

      @credit_report = current_user.credit_reports.build(
        username: username,
        password: password,
        security_question: security_question,
        service: service
      )
      @credit_report.document.attach(io: document_io, filename: document_io.original_filename, content_type: document_io.content_type)

      if @credit_report.save
        parse_credit_report(@credit_report)
        redirect_to challenge_path, notice: 'Credit report successfully imported and parsed.'
      else
        redirect_to new_credit_report_path, alert: 'Failed to save the credit report.'
      end
    else
      redirect_to new_credit_report_path, alert: 'Failed to import credit report.'
    end
  end

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
      @credit_report.extract_scores(json)

      if @credit_report.save
        parse_credit_report(@credit_report)
        redirect_to challenge_path, notice: 'Credit report successfully imported and parsed.'
      else
        redirect_to new_credit_report_path, alert: 'Failed to save the credit report.'
      end
    else
      redirect_to new_credit_report_path, alert: 'Failed to import credit report.'
    end
  end

  def parse_credit_report(credit_report)
    document_content = credit_report.document.download
    
    parser = case credit_report.service
             when 'identityiq'
               IdentityiqParserService.new(document_content)
             when 'creditdyno'
               CreditDynoParserService.new(document_content)
             else
               raise 'Unknown credit report service'
             end
  
    content = parser.extract_content
    process_parsed_content(content, credit_report)
  end

  def process_parsed_content(content, credit_report)
    inquiries = content[:inquiries]
    accounts = content[:accounts]
    

    ActiveRecord::Base.transaction do
      ActiveRecord::Base.connection.execute("DELETE FROM inquiries WHERE user_id = #{current_user.id}")
      BureauDetail.where(account_id: current_user.accounts.pluck(:id)).delete_all
      ActiveRecord::Base.connection.execute("DELETE FROM accounts WHERE user_id = #{current_user.id}")
    end
    

    inquiries.each do |inquiry_attrs|
      inquiry_attrs[:user] = current_user
      Inquiry.create!(inquiry_attrs)
    end
  
    accounts.each do |account_attrs|
      next if account_attrs[:account_number].nil?
  
      account = Account.find_or_create_by!(
        account_number: account_attrs[:account_number],
        user_id: current_user.id
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
end
