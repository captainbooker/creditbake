# app/services/identity_iq_parser_service.rb
class IdentityIQParserService
  def initialize(content)
    @content = Nokogiri::HTML(content)
  end

  def extract_content
    {
      inquiries: extract_inquiries,
      accounts: extract_accounts
    }
  end

  private

  def extract_inquiries
    inquiries = []
    inquiries_section = @content.at_css('div#Inquiries')
    return inquiries unless inquiries_section

    inquiries_table = inquiries_section.at_css('table')
    return inquiries unless inquiries_table

    inquiries_table.css('tr').each do |row|
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

  def extract_accounts
    accounts = []
    account_containers = @content.css('div.account-container') # Adjust the selector based on actual HTML structure

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
