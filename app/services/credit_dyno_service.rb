# app/services/identityiq_service.rb
class CreditDynoService
  BASE_URL = 'https://creditdyno.com/'
  attr_reader :username, :password, :security_question, :service

  def initialize(username, password, security_question, service)
    @username = username
    @password = password
    @service = service
    @security_question = security_question
    @driver = Selenium::WebDriver.for :chrome
    @wait = Selenium::WebDriver::Wait.new(timeout: 20)
  end

  def fetch_credit_report
    login
    navigate_to_credit_report
  end

  private

  def login
    @driver.navigate.to("#{BASE_URL}/customer_login.asp")
    @driver.find_element(name: 'username').send_keys(@username)
    @driver.find_element(name: 'password').send_keys(@password)
    @driver.find_element(:tag_name, 'button').click
  end

  def navigate_to_credit_report
    @driver.navigate.to("#{BASE_URL}/cp6/mcc_creditreports_v2.asp")

    # Get the HTML content
    html_content = @driver.page_source
    html_content
  end
end
