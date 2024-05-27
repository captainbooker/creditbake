# app/services/identityiq_service.rb
class CreditDynoService
  BASE_URL = 'https://creditdyno.com/'

  def self.login(username, password)
    driver = Selenium::WebDriver.for :chrome
    driver.navigate.to "#{BASE_URL}/customer_login.asp"

    driver.find_element(name: 'username').send_keys(username)
    driver.find_element(name: 'password').send_keys(password)
    driver.find_element(:tag_name, 'button').click

    driver
  end

  def self.navigate_to_credit_reports(driver)
    driver.navigate.to("#{BASE_URL}/cp6/mcc_creditreports_v2.asp")
    driver.manage.timeouts.page_load = 10
    driver
  end

  def self.get_arr_container_html(driver)
    wait = Selenium::WebDriver::Wait.new(timeout: 10) 
    element = wait.until { driver.find_element(class: 'arr-container-legacy-sizing').displayed? }
    element = driver.find_element(class: 'arr-container-legacy-sizing')
    element.attribute("outerHTML")
  end
end

