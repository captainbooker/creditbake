class PaymentsController < ApplicationController
  before_action :authenticate_user!
  
  def index
    @spendings = current_user.spendings.order(created_at: :desc).page(params[:page]).per(10)
  end

  def create
  end
end