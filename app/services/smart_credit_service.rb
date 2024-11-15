require 'selenium-webdriver'
require 'json'
require 'logger'

class SmartCreditService
  BASE_URL = 'https://smartcredit.com'
  attr_reader :username, :password, :service, :current_user
  attr_accessor :experian_score, :transunion_score, :equifax_score

  def initialize(user_agent_request, username, password, current_user, browser: :chrome, mobile: false)
    @username = username
    @password = password
    @current_user = current_user
    @browser = browser
    @mobile = mobile
    @user_agent_request = user_agent_request

    @driver = initialize_driver
  rescue Selenium::WebDriver::Error::WebDriverError => e
    raise ArgumentError, "Failed to initialize WebDriver: #{e.message}"
  end

  def fetch_credit_report
    login_result = login
    return login_result if login_result.is_a?(String)

    json_content = fetch_credit_report_json
    return "Error fetching the credit report" unless json_content

    extract_scores(json_content)
    parse_credit_report_json(json_content)
    json_content
  ensure
    @driver.quit if @driver
  end

  private

  def initialize_driver
    options = Selenium::WebDriver::Chrome::Options.new
    if @mobile
      mobile_user_agent = @user_agent_request || 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_5_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.5 Mobile/15E148 Safari/604.1'
      options.add_argument("--user-agent=#{mobile_user_agent}")
    end
    options.add_argument('--headless=new')
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-gpu')
    options.add_argument('--disable-dev-shm-usage')
    options.add_argument('--window-size=1280x800')
    options.add_argument('--disable-extensions')
    options.add_argument('--remote-debugging-port=9222')

    Selenium::WebDriver.for :chrome, options: options
  end

  def login
    @driver.navigate.to "#{BASE_URL}/login/"
    email_field = @driver.find_element(id: 'j_username')
    password_field = @driver.find_element(id: 'j_password')

    email_field.send_keys(@username)
    password_field.send_keys(@password)
    password_field.send_keys(:return)

    wait = Selenium::WebDriver::Wait.new(timeout: 10)
    wait.until { @driver.find_element(css: 'body.member-home') }
  rescue Selenium::WebDriver::Error::NoSuchElementError, Selenium::WebDriver::Error::TimeoutError
    "Wrong username or password"
  end

  def fetch_credit_report_json
    @driver.navigate.to "#{BASE_URL}/member/credit-report/3b/"
    wait = Selenium::WebDriver::Wait.new(timeout: 10)

    account_divs = wait.until { @driver.find_elements(css: '.my-3.border-b.border-5.border-color-gray-300') }
    accounts = account_divs.map { |div| parse_account_div(div) }

    scores = parse_scores
    public_records = parse_public_records
    inquiries = parse_inquiries

    report = {
      "CreditReport" => {
        "Scores" => scores,
        "Accounts" => accounts,
        "PublicRecords" => public_records,
        "Inquiries" => inquiries
      }
    }

    JSON.pretty_generate(report)
  rescue Selenium::WebDriver::Error::NoSuchElementError, Selenium::WebDriver::Error::TimeoutError
    nil
  end

  def parse_account_div(div)
    account_data = {}
    account_data["Creditor"] = div.find_element(css: 'p.mb-3.h6 strong').text

    labels = div.find_elements(css: '.labels .grid-cell')
    transunion_values = div.find_elements(css: '.bg-transunion ~ .grid-cell')
    experian_values = div.find_elements(css: '.bg-experian ~ .grid-cell')
    equifax_values = div.find_elements(css: '.bg-equifax ~ .grid-cell')

    account_data["Transunion"] = format_account_data(labels, transunion_values)
    account_data["Experian"] = format_account_data(labels, experian_values)
    account_data["Equifax"] = format_account_data(labels, equifax_values)

    payment_histories = div.find_elements(css: '.payment-history')
    account_data["PaymentHistory"] = payment_histories.map { |history| parse_payment_history(history) }

    account_data
  end

  def format_account_data(labels, values)
    data = {}
    labels.each_with_index do |label, index|
      data[label.text] = values[index]&.text&.strip
    end
    data
  end

  def parse_payment_history(history_div)
    history_data = {}
    history_data["Bureau"] = history_div.find_element(css: 'p.payment-history-heading').text
    history_data["Payments"] = history_div.find_elements(css: '.status-C, .status-U, .status-9, .status-').map do |status_div|
      {
        "Status" => status_div.find_element(css: '.month-badge').text.strip,
        "Month" => status_div.find_element(css: '.month-label').text.strip
      }
    end
    history_data
  end

  def parse_scores
    scores_section = @driver.find_element(css: 'section.credit-score-3')
    scores = {}

    scores["Transunion"] = scores_section.find_element(css: 'dt.bg-transunion + dd h5').text.strip
    scores["Experian"] = scores_section.find_element(css: 'dt.bg-experian + dd h5').text.strip
    scores["Equifax"] = scores_section.find_element(css: 'dt.bg-equifax + dd h5').text.strip

    scores
  end

  def parse_public_records
    public_records_sections = @driver.find_elements(css: 'section.mt-5')
    public_records = []

    public_records_sections.each do |section|
      next unless section.find_element(css: 'h5.fw-bold').text.strip == 'Public Information'

      labels = section.find_elements(css: '.labels .grid-cell')
      transunion_values = section.find_elements(css: '.bg-transunion ~ .grid-cell')
      experian_values = section.find_elements(css: '.bg-experian ~ .grid-cell')
      equifax_values = section.find_elements(css: '.bg-equifax ~ .grid-cell')

      public_record = format_public_record_data(labels, transunion_values, "Transunion")
      public_records << public_record unless public_record.empty?

      public_record = format_public_record_data(labels, experian_values, "Experian")
      public_records << public_record unless public_record.empty?

      public_record = format_public_record_data(labels, equifax_values, "Equifax")
      public_records << public_record unless public_record.empty?
    end

    public_records
  end

  def parse_inquiries
    inquiries_sections = @driver.find_elements(css: 'section.mt-5')
    inquiries = []

    inquiries_sections.each do |section|
      next unless section.find_element(css: 'h5.fw-bold').text.strip == 'Inquiries'

      inquiry_divs = section.find_elements(css: '.d-grid.grid-cols-3.border-color-gray-100.border-b')
      inquiry_divs.each do |inquiry_div|
        inquiry_data = {}
        inquiry_data["inquiry_name"] = inquiry_div.find_element(css: '.grid-cell:nth-child(1)').text.strip
        inquiry_data["inquiry_date"] = inquiry_div.find_element(css: '.grid-cell:nth-child(2)').text.strip
        inquiry_data["credit_bureau"] = inquiry_div.find_element(css: '.grid-cell:nth-child(3)').text.strip
        inquiries << inquiry_data
      end
    end

    inquiries
  end

  def format_public_record_data(labels, values, bureau)
    data = { "Bureau" => bureau }
    labels.each_with_index do |label, index|
      data[label.text] = values[index]&.text&.strip
    end
    data
  end

  def extract_scores(json_content)
    parsed_json = JSON.parse(json_content)

    scores = extract_all_scores(parsed_json)
    self.experian_score = scores[:experian]
    self.transunion_score = scores[:transunion]
    self.equifax_score = scores[:equifax]
  end

  def extract_all_scores(json)
    scores = { experian: nil, transunion: nil, equifax: nil }

    json.dig("CreditReport", "Scores")&.each do |bureau, score|
      case bureau.downcase
      when 'experian'
        scores[:experian] = score.to_i
      when 'transunion'
        scores[:transunion] = score.to_i
      when 'equifax'
        scores[:equifax] = score.to_i
      end
    end

    scores
  end

  def parse_credit_report_json(json_content)
    credit_report = CreditReport.new
    credit_report.document.attach(io: StringIO.new(json_content), filename: 'credit_report.json', content_type: 'application/json')
    content = JSON.parse(json_content)
    process_parsed_content(content, credit_report)
  end

  def process_parsed_content(content, credit_report)
    inquiries = content.dig("CreditReport", "Inquiries")
    accounts = content.dig("CreditReport", "Accounts")
    public_records = content.dig("CreditReport", "PublicRecords")

    ActiveRecord::Base.transaction do
      clear_existing_records

      create_inquiries(inquiries)
      create_accounts(accounts)
      create_public_records(public_records)
    end
  end

  def clear_existing_records
    user_id = @current_user.id
    ActiveRecord::Base.connection.execute("DELETE FROM inquiries WHERE user_id = #{user_id}")
    BureauDetail.where(account_id: @current_user.accounts.ids).delete_all
    ActiveRecord::Base.connection.execute("DELETE FROM accounts WHERE user_id = #{user_id}")
    BureauDetail.where(public_record_id: @current_user.public_records.ids).delete_all
    ActiveRecord::Base.connection.execute("DELETE FROM public_records WHERE user_id = #{user_id}")
  end

  def create_inquiries(inquiries)
    inquiries.each do |inquiry_attrs|
      inquiry_attrs[:user_id] = @current_user.id
      Inquiry.create!(inquiry_attrs)
    end
  end

  def create_accounts(accounts)
    accounts.each do |account_attrs|
      next if account_attrs.dig("Transunion", "Account #").nil? || account_attrs.dig("Transunion", "Account #") == "--"

      account = Account.find_or_create_by!(
        account_number: account_attrs.dig("Transunion", "Account #"),
        user_id: @current_user.id
      ) do |acc|
        acc.account_type = account_attrs.dig("Transunion", "Account Type")
        acc.account_status = account_attrs.dig("Transunion", "Account Status")
        acc.name = account_attrs["Creditor"]
      end

      create_bureau_details(account, account_attrs)
    end
  end

  def create_bureau_details(account, account_attrs)
    ["Transunion", "Experian", "Equifax"].each do |bureau|
      details = account_attrs[bureau]
      next unless details

      BureauDetail.create!(
        account: account,
        bureau: bureau.downcase.to_sym,
        balance_owed: details["Balance Owed:"],
        high_credit: details["High Balance:"],
        credit_limit: details["Credit Limit:"],
        past_due_amount: details["Past Due Amount:"],
        payment_status: details["Payment Status:"],
        date_opened: details["Date Opened:"],
        date_of_last_payment: details["Last Payment:"],
        public_record_id: nil
      )
    end
  end

  def create_public_records(public_records)
    public_records.each do |public_attrs|
      next if public_attrs.dig("Type") == "--" || public_attrs.dig("Type") == ""

      public_record = PublicRecord.find_or_create_by!(
        public_record_type: public_attrs.dig("Type"),
        user_id: @current_user.id
      ) do |public|
        public.reference_number = public_attrs.dig("Reference#")
      end

      ["Transunion", "Experian", "Equifax"].each do |bureau|
        details = public_attrs[bureau]
        next unless details

        BureauDetail.find_or_create_by!(
          public_record: public_record,
          bureau: bureau.downcase.to_sym,
          status: public_attrs.dig("Status"),
          date_filed_reported: public_attrs.dig("Date Filed/Reported"),
          closing_date: public_attrs.dig("Closing Date"),
          asset_amount: public_attrs.dig("Asset Amount"),
          court: public_attrs.dig("Court"),
          liability: public_attrs.dig("Liability"),
          exempt_amount: public_attrs.dig("Exempt Amount"),
          account_id: nil
        )
      end
    end
  end
end
