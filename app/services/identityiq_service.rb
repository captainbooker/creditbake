require 'selenium-webdriver'
require 'json'
require 'logger'

class IdentityiqService
  BASE_URL = 'https://member.identityiq.com'
  attr_reader :username, :password, :security_question, :service

  def initialize(username, password, security_question, service, browser: :chrome, mobile: false)
    @username = username
    @password = password
    @security_question = security_question
    @service = service
    @browser = browser
    @mobile = mobile
    @logger = Logger.new(STDOUT)

    @driver = initialize_driver
  rescue Selenium::WebDriver::Error::WebDriverError => e
    @logger.error "Failed to initialize #{@browser.capitalize} driver: #{e.message}"
    raise
  end

  def fetch_credit_report
    login
    fetch_credit_report_json
  ensure
    @driver.quit
  end

  private

  def initialize_driver
    case @browser
      when :chrome
        options = Selenium::WebDriver::Chrome::Options.new
        @mobile && options.add_argument('--user-agent=Mozilla/5.0 (iPhone; CPU iPhone OS 17_5_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.5 Mobile/15E148 Safari/604.1')
        options.add_argument('--headless')
        options.add_argument("--no-sandbox")
        options.add_argument("--disable-gpu")
        options.add_argument("--remote-debugging-port=9222")
        Selenium::WebDriver.for :chrome, options: options
      when :firefox
        options = Selenium::WebDriver::Firefox::Options.new
        @mobile && options.add_argument('--user-agent=Mozilla/5.0 (iPhone; CPU iPhone OS 17_5_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.5 Mobile/15E148 Safari/604.1')
        options.add_argument('--headless')
        options.add_argument("--no-sandbox")
        options.add_argument("--disable-gpu")
        options.add_argument("--remote-debugging-port=9222")
        Selenium::WebDriver.for :firefox, options: options
      when :safari
        options = Selenium::WebDriver::Safari::Options.new
        Selenium::WebDriver.for :safari, options: options
      else
        raise ArgumentError, "Unsupported browser: #{@browser}"
    end
  end

  def login
    @logger.info "Navigating to login page"
    @driver.navigate.to "#{BASE_URL}/"
    username_field = @driver.find_element(name: 'username')
    password_field = @driver.find_element(name: 'password')

    username_field.send_keys(@username)
    password_field.send_keys(@password)

    login_button = @driver.find_element(css: 'button[type="submit"]')
    login_button.click
    @logger.info "Submitted login form"
  end

  def fetch_credit_report_json
    @logger.info "Fetching credit report JSON"
    @driver.navigate.to "#{BASE_URL}/CreditReport.aspx?view=json"
    wait = Selenium::WebDriver::Wait.new(timeout: 10)

    json_content = wait.until {
      element = @driver.find_element(:tag_name, 'pre')
      element.text if element.displayed?
    }

    json_content = json_content.sub(/^JSON_CALLBACK\(/, '').sub(/\);?$/, '')
    @logger.info "Credit report JSON fetched successfully"
    json_content
  end
end
