class ApplicationController < ActionController::Base
  add_flash_types :info, :error, :success
  layout :layout_by_resource
  
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to authenticated_root_path, alert: exception.message
  end
  

  rescue_from ActionController::InvalidAuthenticityToken do |exception|
    handle_invalid_authenticity_token(exception)
  end

  before_action :ensure_profile_complete, if: :user_signed_in?
  after_action :record_page_view
  before_action :authorize_access
  before_action :configure_permitted_parameters, if: :devise_controller?

  helper_method :user_browser
  helper_method :mobile?
  helper_method :user_agent_request

  def user_browser
    detect_browser(request.user_agent)
  end

  def user_agent_request
    request.user_agent
  end

  def mobile?
    request.user_agent.include?("Mobile") || request.user_agent.include?("iPhone")
  end

  def handle_exception(exception)
    Rollbar.error(exception)
    flash[:alert] = "Something went wrong. Please try again."
    redirect_to authenticated_root_path # or any other path you consider safe
  end
  

  private

  def handle_invalid_authenticity_token(exception)
    flash[:alert] = "Session has expired. Please try again."
    redirect_to new_user_session_path
  end

  def ensure_profile_complete
    unless current_user.phone_number.present? && current_user.first_name.present? && current_user.last_name.present? &&
           current_user.street_address.present? && current_user.city.present? && current_user.state.present? &&
           current_user.postal_code.present?
      unless request.path == edit_profile_path || request.path == users_update_profile_path
        redirect_to edit_profile_path, notice: "Please complete your profile before proceeding."
      end
    end
  end

  def record_page_view
    # This is a basic example, you might need to customize some conditions.
    # For most sites, it makes no sense to record anything other than HTML.
    if response.content_type && response.content_type.start_with?("text/html")
      # Add a condition to record only your canonical domain
      # and use a gem such as crawler_detect to skip bots.
      ActiveAnalytics.record_request(request)
    end
  end

  def ensure_required_documents
    if current_user.ssn_last4.blank? || !current_user.id_document.attached? || !current_user.utility_bill.attached?
      redirect_to user_settings_path, alert: "Please upload the required fields and documents before proceeding (SSN, ID & Utility Bill)"
      return false
    end
    true
  end
  
  def ensure_required_documents_for_client(client)
    if client.ssn_last4.blank? || !client.id_document.attached? || !client.utility_bill.attached?
      redirect_to edit_client_path(client), alert: "Please upload the required fields and documents before proceeding (SSN, ID & Utility Bill)"
      return false
    end
    true
  end
  

  def detect_browser(user_agent)
    browser = Browser.new(user_agent)
    
    if browser.chrome?
      :chrome
    elsif browser.firefox?
      :firefox
    elsif browser.safari?
      :safari
    elsif browser.edge?
      :edge
    else
      raise "Unsupported browser: #{browser.name}"
    end
  end

  def authorize_access
    protected_paths = ["/blazer", "/analytics", "/sidekiq"]

    if protected_paths.any? { |path| request.path.start_with?(path) }
      authorized_emails = ["darren@creditbake.com", "dbooker.racing@gmail.com"]

      unless authorized_emails.include?(current_user.email)
        redirect_to authenticated_root_path, alert: "Unauthorized access"
      end
    end
  end

  protected

  def layout_by_resource
    if user_signed_in?
      "authenticated"
    else
      "application"
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:agreement])
    devise_parameter_sanitizer.permit(:account_update, keys: [:agreement])
  end
end
