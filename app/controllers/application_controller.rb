class ApplicationController < ActionController::Base
  add_flash_types :info, :error, :success
  layout :layout_by_resource
  
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, alert: exception.message
  end

  private

  def ensure_profile_complete
    if current_user.first_name.blank? || current_user.last_name.blank?
      redirect_to edit_user_registration_path, alert: "Please complete your profile before proceeding."
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
end
