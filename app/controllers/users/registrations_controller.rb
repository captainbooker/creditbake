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
      maverick_customer_creation(current_user)
      create_customer_vault_card_form(current_user)
      redirect_to authenticated_root_path, notice: 'Thanks for completing registration. A few more steps and we are ready to roll!'
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

  def decode_base64_image(data)
    decoded_data = Base64.decode64(data.split(',')[1])
    StringIO.new(decoded_data)
  end

  def missing_required_fields?
    profile_params.values.any?(&:blank?)
  end

  def maverick_customer_creation(user)
    customer_params = {
      "dba": {
          "id": "190265"
      },
      "firstName": user.first_name,
      "lastName": user.last_name,
      "email": user.email,
      "description": "Description to help me identify the customer"
    }
    
    maverick_service = MaverickPayments::CustomerCreationService.new(customer_params)
    response = maverick_service.create_customer
    
    if response.success?
      user.update(
        maverick_customer_id: response["id"],
        maverick_customer_token: response["token"]
      )
    else
      Rollbar.error("Failed to create Maverick Payments customer: #{response.inspect}")
    end
  end
  
  def create_customer_vault_card_form(user)
    return_url = Rails.env.development? ? "https://5cc6-2600-8801-3890-6f00-f467-74b0-b97b-ebd9.ngrok-free.app/upgrade_plan?status=<status>&customerId=<customerId>&cardId=<cardId>" : "https://www.creditbake.com/upgrade_plan?status=<status>&customerId=<customerId>&cardId=<cardId>"
    card_form_params = {
      "dba": {
        "id": "190265"
      },
      "terminal": {
        "id": "415304"
      },
      "customerVault": {
        "id": user.maverick_customer_id
      },
      "returnUrl": return_url,
      "returnUrlNavigation": ""
    }
  
    maverick_service = MaverickPayments::CustomerCreationService.new(card_form_params)
    response = maverick_service.create_customer_vault_card_form
  
    if response.success?
      user.update(maverick_hosted_form_url: response["url"])
    else
      Rollbar.error("Failed to create customer vault card form: #{response.inspect}")
    end
  end
end

