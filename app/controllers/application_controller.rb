class ApplicationController < ActionController::Base
  layout :layout_by_resource
  
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, alert: exception.message
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
