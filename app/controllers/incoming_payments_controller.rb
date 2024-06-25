class IncomingPaymentsController < ApplicationController
  before_action :authenticate_user!

  def maverick
    transaction_id = params[:id]

    service = PaymentService.new(transaction_id)
    result = service.fetch_payment_details

    if result[:status] == 'Success'
      user = current_user
      amount = result[:amount]
      
      if user
        user.increment!(:credits, amount)
        Spending.create!(user: user, amount: amount, description: "Credits Added")
        flash[:notice] = "Credits added successfully."
      else
        flash[:alert] = "User not found."
      end
    else
      flash[:alert] = "Credit did not get added to your account"
    end

    redirect_to authenticated_root_path
  end
end
