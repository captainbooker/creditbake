# app/controllers/payments_controller.rb
class PaymentsController < ApplicationController
  def new
  end

  def create
    # Integrate with your payment gateway here
    # Redirect to create_attack with payment success flag
    redirect_to create_attack_path(round: params[:round], payment_success: 'true')
  end
end
