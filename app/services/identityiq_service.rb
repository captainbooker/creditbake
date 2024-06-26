require 'selenium-webdriver'
require 'json'

class IdentityiqService
  BASE_URL = 'https://member.identityiq.com'
  attr_reader :username, :password, :security_question, :service

  def initialize(user_agent_request, username, password, security_question, browser: :chrome, mobile: false)
    @username = username
    @password = password
    @security_question = security_question
    @browser = browser
    @mobile = mobile
    @user_agent_request = user_agent_request

    @driver = initialize_driver
  rescue Selenium::WebDriver::Error::WebDriverError => e
    Rollbar.error(e, "Failed to fetch credit report JSON")
    raise
  end

  def fetch_credit_report
    login
    fetch_credit_report_json
  ensure
    @driver&.quit
  end

  private

  def initialize_driver
    case @browser
    when :chrome
      options = Selenium::WebDriver::Chrome::Options.new
      if @mobile
        mobile_user_agent = @user_agent_request || 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_5_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.5 Mobile/15E148 Safari/604.1'
        options.add_argument("--user-agent=#{mobile_user_agent}")
      end
      options.add_argument('--headless=new')  # Using the new headless mode for better performance
      options.add_argument('--no-sandbox')
      options.add_argument('--disable-gpu')
      options.add_argument('--disable-dev-shm-usage')
      options.add_argument('--window-size=1280x800')
      options.add_argument('--disable-extensions')
      options.add_argument('--remote-debugging-port=9222')
      Selenium::WebDriver.for :chrome, options: options
    else
      raise ArgumentError, "Unsupported browser: #{@browser}"
    end
  end

  def login
    @driver.navigate.to "#{BASE_URL}/"
    username_field = @driver.find_element(name: 'username')
    password_field = @driver.find_element(name: 'password')

    username_field.send_keys(@username)
    password_field.send_keys(@password)

    login_button = @driver.find_element(css: 'button[type="submit"]')
    login_button.click
  rescue Selenium::WebDriver::Error::NoSuchElementError, Selenium::WebDriver::Error::TimeoutError => e
    Rollbar.error(e, "Failed to fetch credit report JSON")
    return "Wrong username or password"
  end

  def fetch_credit_report_json
    @driver.navigate.to "#{BASE_URL}/CreditReport.aspx?view=json"
    wait = Selenium::WebDriver::Wait.new(timeout: 10)

    json_content = wait.until {
      element = @driver.find_element(:tag_name, 'pre')
      element.text if element.displayed?
    }

    json_content = json_content.sub(/^JSON_CALLBACK\(/, '').sub(/\);?$/, '')
    json_content

  rescue Selenium::WebDriver::Error::NoSuchElementError, Selenium::WebDriver::Error::TimeoutError => e
    Rollbar.error(e, "Failed to fetch credit report JSON")
    return "Wrong username or password"
  end
end
