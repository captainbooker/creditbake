module ImportCreditReports
  extend ActiveSupport::Concern

  def import
    user_browser = detect_browser(request.user_agent)
  
    service = params[:service]
    username = params[:username]
    password = params[:password]
    security_question = params[:security_question]
    
    
    FetchCreditReportJob.perform_later(username, password, security_question, service, current_user.id, :chrome, request.user_agent, user_agent_request)
    redirect_to credit_report_path, notice: 'We are importing your credit report. This process should only take a few minutes. You will receive an email once the import is finished, or you can check the "Challenge" page for updates.'
    return
  end  
end
