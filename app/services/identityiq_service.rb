require 'selenium-webdriver'
require 'json'
require 'logger'

class IdentityiqService
  BASE_URL = 'https://member.identityiq.com'
  attr_reader :username, :password, :security_question, :service

  def initialize(username, password, security_question,  browser: :chrome, mobile: false)
    @username = username
    @password = password
    @security_question = security_question
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
      @mobile && options.add_argument('--user-agent=Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537')
      options.add_argument('--headless')
      options.add_argument('--no-sandbox')
      options.add_argument('--disable-gpu')
      if ENV['ENABLE_REMOTE_DEBUGGING']
        options.add_argument('--remote-debugging-port=9222')
      end
      Selenium::WebDriver.for :chrome, options: options
  
    when :firefox
      options = Selenium::WebDriver::Firefox::Options.new
      @mobile && options.add_argument('--user-agent=Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537')
      options.add_argument('--headless')
      options.add_argument('--no-sandbox')
      options.add_argument('--disable-gpu')
      Selenium::WebDriver.for :firefox, options: options
  
    when :safari
      options = Selenium::WebDriver::Chrome::Options.new
      @mobile && options.add_argument('--user-agent=Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537')
      options.add_argument('--headless')
      options.add_argument('--no-sandbox')
      options.add_argument('--disable-gpu')
      if ENV['ENABLE_REMOTE_DEBUGGING']
        options.add_argument('--remote-debugging-port=9222')
      end
      Selenium::WebDriver.for :chrome, options: options
    when :edge
      options = Selenium::WebDriver::Edge::Options.new
      options.add_argument('--headless')
      options.add_argument('--no-sandbox')
      options.add_argument('--disable-gpu')
      Selenium::WebDriver.for :edge, options: options
  
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
  rescue Selenium::WebDriver::Error::NoSuchElementError, Selenium::WebDriver::Error::TimeoutError
    return "Wrong username or password"
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

  rescue Selenium::WebDriver::Error::NoSuchElementError, Selenium::WebDriver::Error::TimeoutError
    return "Wrong username or password"
  end
end
