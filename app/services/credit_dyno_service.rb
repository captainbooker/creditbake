# app/services/identityiq_service.rb
class CreditDynoService
  BASE_URL = 'https://creditdyno.com'

  def self.login(username, password, security_question, service)
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

    driver.navigate.to("#{BASE_URL}/cp6/mcc_creditreports_v2.asp")

    array_credit_report = wait.until {
      element = driver.find_element(:css, 'array-credit-report[reportkey="2b8efe89-2024-47b2-b9c1-d045da7d3f34"]')
      element if element.displayed?
    }

    shadow_root = driver.execute_script('return arguments[0].shadowRoot', array_credit_report)
    element_inside_shadow = shadow_root.find_element(:class, 'arr-container-legacy-sizing')

    # Retrieve the outerHTML of the element
    wait.until { element_inside_shadow.displayed? }
    sleep(8)

    svg_elements = shadow_root.find_elements(:css, 'svg.arr-collapsible-icon')
    svg_elements.each do |svg_element|
      begin
        if svg_element.displayed? && svg_element.enabled?
          svg_element.click
          sleep(0.5)  # Optional: wait for a short time to let the UI update
        end
      rescue Selenium::WebDriver::Error::ElementNotInteractableError
        next  # If the element is not interactable, move to the next one
      end
    end

    element_html = element_inside_shadow.attribute("innerHTML")
    element_html
  end
end