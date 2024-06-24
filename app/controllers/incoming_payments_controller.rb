class IncomingPaymentsController < ApplicationController
  before_action :authenticate_user!

  def maverick
    status = params[:status]
    user_id = params[:externalId]
    amount = params[:amount].to_f

    if status == 'Success'
      user = User.find_by(id: user_id)
      if user
        user.increment!(:credits, amount)
        flash[:notice] = "Credits added successfully."
        redirect_to authenticated_root_path
      else
        flash[:alert] = "User not found."
        redirect_to authenticated_root_path
      end
    else
      flash[:alert] = "Credit did not get added to your account"
      redirect_to authenticated_root_path
    end
  end
end

