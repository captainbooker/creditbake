class ApplicationController < ActionController::Base
  add_flash_types :info, :error, :success
  layout :layout_by_resource
  
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, alert: exception.message
  end

  before_action :ensure_profile_complete, if: :user_signed_in?

  private

  def ensure_profile_complete
    unless current_user.phone_number.present? && current_user.first_name.present? && current_user.last_name.present? &&
           current_user.street_address.present? && current_user.city.present? && current_user.state.present? &&
           current_user.postal_code.present?
      unless request.path == edit_profile_path || request.path == users_update_profile_path
        redirect_to edit_profile_path, alert: "Please complete your profile before proceeding."
      end
    end
  end

  def ensure_required_documents
    if current_user.ssn_last4.blank? || !current_user.id_document.attached? || !current_user.utility_bill.attached?
      redirect_to settings_path, alert: "Please upload the required documents before proceeding."
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
