# app/controllers/client_profiles_controller.rb
class ClientProfilesController < ApplicationController
  before_action :set_client_profile, only: [:show, :edit, :update, :destroy]

  def new
    @client_profile = ClientProfile.new
  end

  def create
    @client_profile = ClientProfile.new(client_profile_params)
    @client_profile.client = current_user.client

    if @client_profile.save
      redirect_to @client_profile, notice: 'Client profile was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @client_profile.update(client_profile_params)
      redirect_to @client_profile, notice: 'Client profile was successfully updated.'
    else
      render :edit
    end
  end

  def show
  end

  private

  def set_client_profile
    @client_profile = ClientProfile.find(params[:id])
  end

  def client_profile_params
    params.require(:client_profile).permit(:first_name, :middle_name, :last_name, :ssn_last4, :address, :email, :phone, :id_document, :utility_bill)
  end
end
