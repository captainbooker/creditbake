require 'selenium-webdriver'
require 'json'
require 'logger'

class IdentityiqService
  BASE_URL = 'https://member.identityiq.com'
  attr_reader :username, :password, :security_question, :service

  def initialize(username, password, security_question, service)
    @username = username
    @password = password
    @security_question = security_question
    @service = service
    @logger = Logger.new(STDOUT)

    # Configure Chrome options to run in headless mode
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--headless') # Run in headless mode
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-dev-shm-usage')
    options.add_argument('--disable-gpu') # Disable GPU hardware acceleration
    options.add_argument('--window-size=1920,1080') # Set a default window size
    options.add_argument('--disable-software-rasterizer')
    options.add_argument('--remote-debugging-port=9222')
    options.add_argument('--single-process')

    @driver = Selenium::WebDriver.for :chrome, options: options
  rescue Selenium::WebDriver::Error::WebDriverError => e
    @logger.error "Failed to initialize Chrome driver: #{e.message}"
    raise
  end

  def fetch_credit_report
    login
    fetch_credit_report_json
  ensure
    @driver.quit
  end

  private

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
