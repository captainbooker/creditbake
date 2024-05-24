require 'nokogiri'

class CreditReportsController < ApplicationController
  # before_action :set_client
  before_action :set_credit_report, only: [:show]

  def new
    @credit_report = CreditReport.new
  end

  def create
    @credit_report = current_user.credit_reports.build(credit_report_params)

    if @credit_report.save
      # Extract HTML content from the uploaded document
      html_parser_service = HtmlParserService.new(@credit_report.document)
      document_content = html_parser_service.extract_content

      # Process the parsed content and save the parsed data into Dispute model
      process_parsed_content(document_content, @credit_report)

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
      import_identityiq_credit_report(username, password, security_question)
    when 'creditdyno'
      import_credit_dyno_credit_report(username, password, security_question)
    else
      redirect_to new_credit_report_path, alert: 'Invalid service selected.'
    end
  end

  def show
  end

  private

  # def set_client
  #   @client = Client.find(params[:client_id])
  # end

  def set_credit_report
    @credit_report = current_user.credit_report
  end

  def credit_report_params
    params.require(:credit_report).permit(:document, :service, :username, :password, :security_question)
  end

  def import_identityiq_credit_report(username, password, security_question)
    service = IdentityiqService.new(username, password, security_question)
    credit_report_path = service.fetch_credit_report

    if credit_report_path
      @credit_report = current_user.credit_reports.build(
        document: File.open(credit_report_path),
        username: username,
        password: password,
        security_question: security_question
      )
      

      if @credit_report.save
        html_parser_service = HtmlParserService.new(@credit_report.document)
        document_content = html_parser_service.extract_content

        # Process the parsed content and save the parsed data into Dispute model
        process_parsed_content(document_content, @credit_report)

        redirect_to root_path, notice: 'Credit report successfully imported and parsed.'
      else
        redirect_to new_credit_report_path, alert: 'Failed to save the credit report.'
      end
    else
      redirect_to new_credit_report_path, alert: 'Failed to import credit report.'
    end
  end

  def import_credit_dyno_credit_report(username, password, security_question)
    service = CreditDynoService.new(username, password, security_question)
    credit_report_path = service.fetch_credit_report

    if credit_report_path
      @credit_report = current_user.credit_reports.build(
        document: File.open(credit_report_path),
        username: username,
        password: password,
        security_question: security_question
      )
      

      if @credit_report.save
        html_parser_service = HtmlParserService.new(@credit_report.document)
        document_content = html_parser_service.extract_content

        # Process the parsed content and save the parsed data into Dispute model
        process_parsed_content(document_content, @credit_report)

        redirect_to root_path, notice: 'Credit report successfully imported and parsed.'
      else
        redirect_to new_credit_report_path, alert: 'Failed to save the credit report.'
      end
    else
      redirect_to new_credit_report_path, alert: 'Failed to import credit report.'
    end
  end

  def extract_inquiries(content)
    inquiries = []
    inquiries_section = content.at_css('div#Inquiries')
    return inquiries unless inquiries_section

    inquiries_table = inquiries_section.at_css('table.rpt_content_table')
    return inquiries unless inquiries_table

    inquiries_table.css('tbody tr.ng-scope').each do |row|
      cells = row.css('td')
      next if cells.empty?

      inquiries << {
        inquiry_name: cells[0].text.strip,
        type_of_business: cells[1].text.strip,
        inquiry_date: cells[2].text.strip,
        credit_bureau: cells[3].text.strip,
        user: current_user
      }
    end
    inquiries
  end

  def process_parsed_content(content, credit_report)
    inquiries = extract_inquiries(content)
  
    inquiries.each do |inquiry_attrs|
      inquiry = Inquiry.create!(inquiry_attrs)
      # @client.disputes.create!(
      #   credit_report: credit_report,
      #   disputable: inquiry,
      #   category: 'inquiry'
      # )
    end
    
    accounts = extract_accounts(content)
    
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
  
      # @client.disputes.create!(
      #   credit_report: credit_report,
      #   disputable: account,
      #   category: 'account'
      # )
    end
  end
  
  def extract_accounts(content)
    accounts = []
  
    account_containers = content.css('table.rpt_table4column')
  
    account_containers.each do |container|
      account_number = extract_detail(container, 'Account #:').first
      account_type = extract_detail(container, 'Account Type:').first
      account_type_detail = extract_detail(container, 'Account Type - Detail:').first
      account_status = extract_detail(container, 'Account Status:').first
      balance_owed = extract_detail(container, 'Balance:')
      high_credit = extract_detail(container, 'High Credit:')
      credit_limit = extract_detail(container, 'Credit Limit:')
      past_due_amount = extract_detail(container, 'Past Due:')
      payment_status = extract_detail(container, 'Payment Status:')
      date_opened = extract_detail(container, 'Date Opened:')
      date_of_last_payment = extract_detail(container, 'Date of Last Payment:')
      last_reported = extract_detail(container, 'Last Reported:')
  
      accounts << {
        account_number: account_number,
        account_type: account_type,
        account_type_detail: account_type_detail,
        account_status: account_status,
        transunion_balance_owed: balance_owed[0],
        experian_balance_owed: balance_owed[1],
        equifax_balance_owed: balance_owed[2],
        transunion_high_credit: high_credit[0],
        experian_high_credit: high_credit[1],
        equifax_high_credit: high_credit[2],
        transunion_credit_limit: credit_limit[0],
        experian_credit_limit: credit_limit[1],
        equifax_credit_limit: credit_limit[2],
        transunion_past_due_amount: past_due_amount[0],
        experian_past_due_amount: past_due_amount[1],
        equifax_past_due_amount: past_due_amount[2],
        transunion_payment_status: payment_status[0],
        experian_payment_status: payment_status[1],
        equifax_payment_status: payment_status[2],
        transunion_date_opened: date_opened[0],
        experian_date_opened: date_opened[1],
        equifax_date_opened: date_opened[2],
        transunion_date_of_last_payment: date_of_last_payment[0],
        experian_date_of_last_payment: date_of_last_payment[1],
        equifax_date_of_last_payment: date_of_last_payment[2],
        transunion_last_reported: last_reported[0],
        experian_last_reported: last_reported[1],
        equifax_last_reported: last_reported[2]
      }
    end
  
    accounts
  end
  
  def extract_detail(container, detail_name)
    container.xpath(".//td[contains(text(),\"#{detail_name}\")]/following-sibling::td").map(&:text).map(&:strip)
  end  
end
