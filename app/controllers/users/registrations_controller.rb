class Users::RegistrationsController < Devise::RegistrationsController
  before_action :authenticate_user!, only: [:edit_profile, :update_profile]
  skip_before_action :ensure_profile_complete, only: [:edit_profile, :update_profile]

  def create
    super
  end

  def edit_profile
    # Custom logic for the profile setup step
  end

  def update_profile
    current_user.assign_attributes(profile_params)
    
    if params[:signature_data].present?
      signature_io = decode_base64_image(params[:signature_data])
      current_user.signature.attach(io: signature_io, filename: 'signature.png', content_type: 'image/png')
    end
    
    if missing_required_fields? || current_user.signature.blank?
      redirect_to edit_profile_path, alert: 'Profile could not be updated. Please ensure all fields are filled out and a signature is provided.'
    elsif current_user.save
      redirect_to authenticated_root_path, notice: 'Profile updated successfully.'
    else
      render :edit_profile
    end
  end

  protected

  def profile_params
    params.require(:user).permit(:first_name, :agreement, :last_name, :phone_number, :street_address, :city, :state, :postal_code, :country, :ssn_last4)
  end

  def after_sign_up_path_for(resource)
    edit_profile_path # Redirect to the profile setup step
  end

  def decode_base64_image(data)
    decoded_data = Base64.decode64(data.split(',')[1])
    StringIO.new(decoded_data)
  end

  def missing_required_fields?
    profile_params.values.any?(&:blank?)
  end
end

