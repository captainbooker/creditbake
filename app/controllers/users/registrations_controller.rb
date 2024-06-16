class Users::RegistrationsController < Devise::RegistrationsController
  before_action :authenticate_user!, only: [:edit_profile, :update_profile]
  skip_before_action :ensure_profile_complete, only: [:edit_profile, :update_profile]

  def create
    super do |resource|
      resource.credits = 0 # or any default value
      resource.save
    end
  end
  
  def edit_profile
    # Custom logic for the profile setup step
  end

  def update_profile
    if current_user.update(profile_params)
      redirect_to authenticated_root_path, notice: 'Profile updated successfully.'
    else
      render :edit_profile
    end
  end

  protected

  def profile_params
    params.require(:user).permit(:first_name, :last_name, :phone_number, :street_address, :city, :state, :postal_code, :country, :ssn_last4)
  end

  def after_sign_up_path_for(resource)
    edit_profile_path # Redirect to the profile setup step
  end
end
