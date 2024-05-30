class CreditDynoParserService
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
    inquiries_section = @content.css('div.account-record.svelte-1vus6ng')
    return inquiries if inquiries_section.empty?
  
    inquiries_section.each do |record|
      inquiry_date = record.at_css('p.date.arr-text-xs')&.text&.strip
      inquiry_name = record.at_css('p.type.arr-title-sm.svelte-48lqnw')&.text&.strip
      type_of_business = record.at_css('p.level.arr-text-sm.svelte-48lqnw')&.text&.strip
      address_elements = record.css('div.creditor-info p.address')
      bureau = record.at_css('p.bureau.arr-title-sm')&.text&.strip
      address = address_elements.map(&:text).join(', ')
  
      puts "Inquiry Date: #{inquiry_date}"  # Debugging statement
      puts "Inquiry Name: #{inquiry_name}"  # Debugging statement
      puts "Type of Business: #{type_of_business}"  # Debugging statement
      puts "Bureau: #{bureau}"  # Debugging statement
      puts "Address: #{address}"  # Debugging statement
  
      next unless inquiry_date.present?
      next unless bureau.present?
  
      inquiries << {
        inquiry_name: inquiry_name,
        type_of_business: type_of_business,
        inquiry_date: inquiry_date,
        address: address,
        credit_bureau: bureau
      }
    end
    inquiries
  end  

  def extract_accounts
    accounts = []
    account_containers = @content.css('div.account-record[class*="svelte-"]')
    
    bureaus = [:transunion, :equifax, :experian]
    
    account_containers.each_slice(3) do |account_set|
      account_set.each_with_index do |container, index|
        bureau = bureaus[index]
  
        account_details = container.css('div[class*="account-details"] .field-row')
  
        raw_account_number = extract_detail(account_details, 'Account number')
        account_number = normalize_account_number(raw_account_number)
        account_status = extract_detail(account_details, 'Account status') || extract_detail(account_details, 'Status')
        account_type = extract_detail(account_details, 'Type') || extract_detail(account_details, 'Current rating')

        next if raw_account_number.empty?
  
        account = accounts.find { |acc| acc[:account_number] == account_number }

        if account.nil?
          account = { account_number: account_number, account_status: account_status, account_type: account_type, bureau_details: {} }
          accounts << account
        end
        
        account[:bureau_details][bureau] = {
          credit_limit: extract_detail(account_details, 'Credit limit'),
          high_balance: extract_detail(account_details, 'High balance'),
          high_credit: extract_detail(account_details, 'High credit'),
          past_due_amount: extract_detail(account_details, 'Amount past due') || extract_detail(account_details, 'Unpaid balance'),
          payment_status: extract_detail(account_details, 'Current payment status') || extract_detail(account_details, 'Status'),
          date_opened: extract_detail(account_details, 'Open date') || extract_detail(account_details, 'Date opened'),
          date_of_last_payment: extract_detail(account_details, 'Last activity')
        }
      end
    end
    accounts
  end
  
  def extract_detail(container, detail_name)
    detail = container.find { |field| field.at_css('div.label').text.strip == detail_name }
    detail ? detail.at_css('div.value').text.strip : ''
  end
  
  def normalize_account_number(account_number)
    account_number.gsub('X', '')
  end  
end

class XPathLiteral
  def initialize(literal)
    @literal = literal
  end

  def to_s
    parts = @literal.split("'")
    if parts.length == 1
      "'#{@literal}'"
    else
      "concat(#{parts.map { |part| "'#{part}'" }.join(", \"'\", ")})"
    end
  end
end
