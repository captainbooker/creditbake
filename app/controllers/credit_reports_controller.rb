# app/controllers/credit_reports_controller.rb
class CreditReportsController < ApplicationController
  before_action :set_credit_report, only: [:show]

  def new
    @credit_report = CreditReport.new
  end

  def create
    @credit_report = current_user.credit_reports.build(credit_report_params)

    if @credit_report.save
      parse_credit_report(@credit_report)
      redirect_to root_path, notice: 'Credit report successfully uploaded and parsed.'
    else
      render :new
    end
  end

  def import
    service = params[:service]
    username = params[:username]
    password = params[:password]
    security_question = params[:security_question]

    case service
    when 'identityiq'
      import_credit_report(IdentityiqService.new(username, password, security_question, service))
    when 'creditdyno'
      import_credit_report(CreditDynoService.new(username, password, security_question, service))
    else
      redirect_to new_credit_report_path, alert: 'Invalid service selected.'
    end
  end

  def show
  end

  private

  def set_credit_report
    @credit_report = current_user.credit_report
  end

  def credit_report_params
    params.require(:credit_report).permit(:document, :service, :username, :password, :security_question)
  end

  def import_credit_report(service)
    html_content = service.fetch_credit_report

    if html_content
      # Use StringIO to create an in-memory file-like object
      document_io = StringIO.new(html_content)
      document_io.class.class_eval { attr_accessor :original_filename, :content_type }
      document_io.original_filename = 'credit_report.html'
      document_io.content_type = 'text/html'

      @credit_report = current_user.credit_reports.build(
        username: service.username,
        password: service.password,
        security_question: service.security_question,
        service: service.service
      )
      @credit_report.document.attach(io: document_io, filename: document_io.original_filename, content_type: document_io.content_type)

      if @credit_report.save
        parse_credit_report(@credit_report)
        redirect_to root_path, notice: 'Credit report successfully imported and parsed.'
      else
        redirect_to new_credit_report_path, alert: 'Failed to save the credit report.'
      end
    else
      redirect_to new_credit_report_path, alert: 'Failed to import credit report.'
    end
  end

  def parse_credit_report(credit_report)
    case credit_report.service
    when 'identityiq'
      parser = IdentityIQParserService.new(credit_report.document.download)
    when 'creditdyno'
      parser = CreditDynoParserService.new(credit_report.document.download)
    else
      raise 'Unknown credit report service'
    end

    document_content = parser.extract_content
    process_parsed_content(document_content, credit_report)
  end

  def process_parsed_content(content, credit_report)
    inquiries = content[:inquiries]
    accounts = content[:accounts]

    inquiries.each do |inquiry_attrs|
      Inquiry.create!(inquiry_attrs)
    end

    accounts.each do |account_attrs|
      next if account_attrs[:account_number].nil?

      account = Account.create!(
        account_number: account_attrs[:account_number],
        account_type: account_attrs[:account_type],
        account_type_detail: account_attrs[:account_type_detail],
        account_status: account_attrs[:account_status],
        user: current_user
      )

      %i[transunion experian equifax].each do |bureau|
        if account_attrs[:"#{bureau}_balance_owed"].present?
          BureauDetail.create!(
            account: account,
            bureau: bureau,
            balance_owed: account_attrs[:"#{bureau}_balance_owed"],
            high_credit: account_attrs[:"#{bureau}_high_credit"],
            credit_limit: account_attrs[:"#{bureau}_credit_limit"],
            past_due_amount: account_attrs[:"#{bureau}_past_due_amount"],
            payment_status: account_attrs[:"#{bureau}_payment_status"],
            date_opened: account_attrs[:"#{bureau}_date_opened"],
            date_of_last_payment: account_attrs[:"#{bureau}_date_of_last_payment"],
            last_reported: account_attrs[:"#{bureau}_last_reported"]
          )
        end
      end
    end
  end
end
