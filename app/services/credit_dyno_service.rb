# app/services/identityiq_service.rb
class CreditDynoService
  BASE_URL = 'https://creditdyno.com/'
  attr_reader :username, :password, :security_question, :service

  def initialize(username, password, security_question, service)
    @username = username
    @password = password
    @security_question = security_question
    @service = service
    @agent = Mechanize.new
  end

  def fetch_credit_report
    login
    navigate_to_credit_report
  end

  private

  def login
    login_page = @agent.get("#{BASE_URL}/customer_login.asp")
    login_form = login_page.form_with(id: 'CFForm_1') do |form|
      form.username = @username
      form.password = @password
    end
    @agent.submit(login_form)
  end

  def navigate_to_credit_report
    # Assuming that the credit report is accessible at a specific URL after login
    # Replace '/path-to-credit-report' with the actual path
    report_page = @agent.get("#{BASE_URL}/cp6/mcc_creditreports_v2.asp")
    report_page.body
    # Logic to extract and save the credit report from the report_page
    # For example, downloading a PDF or parsing HTML data
  end
end
