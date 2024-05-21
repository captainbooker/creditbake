require 'nokogiri'

class CreditReportsController < ApplicationController
  before_action :set_client
  before_action :set_credit_report, only: [:show]

  def new
    @credit_report = CreditReport.new
  end

  def create
    @credit_report = @client.credit_reports.new(credit_report_params)

    if @credit_report.save
      # Extract HTML content from the uploaded document
      html_parser_service = HtmlParserService.new(@credit_report.document)
      document_content = html_parser_service.extract_content

      # Process the parsed content and save the parsed data into Dispute model
      process_parsed_content(document_content, @credit_report)

      redirect_to client_credit_report_path(@client, @credit_report), notice: 'Credit report successfully uploaded and parsed.'
    else
      render :new
    end
  end

  def show
  end

  private

  def set_client
    @client = Client.find(params[:client_id])
  end

  def set_credit_report
    @credit_report = @client.credit_reports.find(params[:id])
  end

  def credit_report_params
    params.require(:credit_report).permit(:document)
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
      account = Account.create!(
        account_number: account_attrs[:account_number],
        account_type: account_attrs[:account_type],
        account_type_detail: account_attrs[:account_type_detail],
        account_status: account_attrs[:account_status]
      )

      %i[transunion experian equifax].each do |bureau|
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

      # @client.disputes.create!(
      #   credit_report: credit_report,
      #   disputable: account,
      #   category: 'account'
      # )
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
        credit_bureau: cells[3].text.strip
      }
    end
    inquiries
  end

  def extract_accounts(content)
    accounts = []
    accounts_table = content.css('table.rpt_table4column')
    return accounts unless accounts_table

    accounts_table.each do |table|
      account_number = table.xpath('//td[contains(text(),"Account #:")]/following-sibling::td').map(&:text).map(&:strip)
      account_type = table.xpath('//td[contains(text(),"Account Type:")]/following-sibling::td').map(&:text).map(&:strip)
      account_type_detail = table.xpath('//td[contains(text(),"Account Type - Detail:")]/following-sibling::td').map(&:text).map(&:strip)
      account_status = table.xpath('//td[contains(text(),"Account Status:")]/following-sibling::td').map(&:text).map(&:strip)
      balance_owed = table.xpath('//td[contains(text(),"Balance:")]/following-sibling::td').map(&:text).map(&:strip)
      high_credit = table.xpath('//td[contains(text(),"High Credit:")]/following-sibling::td').map(&:text).map(&:strip)
      credit_limit = table.xpath('//td[contains(text(),"Credit Limit:")]/following-sibling::td').map(&:text).map(&:strip)
      past_due_amount = table.xpath('//td[contains(text(),"Past Due:")]/following-sibling::td').map(&:text).map(&:strip)
      payment_status = table.xpath('//td[contains(text(),"Payment Status:")]/following-sibling::td').map(&:text).map(&:strip)
      date_opened = table.xpath('//td[contains(text(),"Date Opened:")]/following-sibling::td').map(&:text).map(&:strip)
      date_of_last_payment = table.xpath('//td[contains(text(),"Date of Last Payment:")]/following-sibling::td').map(&:text).map(&:strip)
      last_reported = table.xpath('//td[contains(text(),"Last Reported:")]/following-sibling::td').map(&:text).map(&:strip)

      accounts << {
        account_number: account_number[0],
        account_type: account_type[0],
        account_type_detail: account_type_detail[0],
        account_status: account_status[0],
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
end
