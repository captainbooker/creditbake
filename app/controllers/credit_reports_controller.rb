require 'zip'

class CreditReportsController < ApplicationController
  include ImportCreditReports
  include ParseCreditReports
  include DownloadFiles

  before_action :set_credit_report, only: [:show, :download]

  def new
    @credit_report = CreditReport.new
  end

  def show
  end

  def credit_report
    @user_browser = detect_browser(request.user_agent)
    @credit_reports = current_user.credit_reports
  end

  def create
    if params[:client_id].present?
      client = Client.find(params[:client_id])
      @credit_report = client.credit_reports.build(credit_report_params)

      if @credit_report.save
        parse_credit_report(@credit_report)
        redirect_to authenticated_root_path, notice: 'Credit report successfully uploaded and parsed.'
      else
        render :new
      end
    else
      @credit_report = current_user.credit_reports.build(credit_report_params)

      if @credit_report.save
        parse_credit_report(@credit_report)
        redirect_to authenticated_root_path, notice: 'Credit report successfully uploaded and parsed.'
      else
        render :new
      end
    end
  end

  private

  def set_credit_report
    @credit_report = current_user.credit_reports.find(params[:id])
  end

  def credit_report_params
    params.require(:credit_report).permit(:document, :service, :username, :password, :security_question)
  end
end
