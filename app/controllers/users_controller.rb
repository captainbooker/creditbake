# app/controllers/users_controller.rb
class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user

  def settings
  end

  def update
    if user_params[:ssn_last4].blank?
      user_params.delete(:ssn_last4)
    end
    if @user.update(user_params)
      redirect_to authenticated_root_path, notice: 'Profile updated successfully.'
    else
      render :settings
    end
  end

  def delete_id_document
    @user.id_document.purge
    redirect_to authenticated_root_path, notice: 'ID Document was successfully deleted.'
  end

  def delete_utility_bill
    @user.utility_bill.purge
    redirect_to authenticated_root_path, notice: 'Utility Bill was successfully deleted.'
  end

  private

  def set_user
    @user = current_user
  end

  def user_params
    params.require(:user).permit(:email, :signature_data, :first_name, :last_name, :phone_number, :street_address, :city, :state, :postal_code, :country, :ssn_last4, :id_document, :utility_bill, :additional_document1, :additional_document2, :free_attack)
  end
end
