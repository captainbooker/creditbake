require 'selenium-webdriver'
require 'json'

class IdentityiqService
  BASE_URL = 'https://member.identityiq.com'
  attr_reader :username, :password, :security_question, :service

  def initialize(username, password, security_question, service)
    @username = username
    @password = password
    @security_question = security_question
    @service = service
    @driver = Selenium::WebDriver.for :chrome
  end

  def fetch_credit_report
    login
    fetch_credit_report_json
  ensure
    @driver.quit
  end

  private

  def login
    @driver.navigate.to "#{BASE_URL}/"
    username_field = @driver.find_element(name: 'username')
    password_field = @driver.find_element(name: 'password')

    username_field.send_keys(@username)
    password_field.send_keys(@password)

    login_button = @driver.find_element(css: 'button[type="submit"]')
    login_button.click

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
  end
end