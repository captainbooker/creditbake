class IncomingPaymentsController < ApplicationController
  before_action :authenticate_user!

  def maverick
    transaction_id = params[:id]

    service = PaymentService.new(transaction_id)
    result = service.fetch_payment_details

    puts "######## MICHAEL JACKSON #{result}"
    if result[:status] == 'Approved'
      user = current_user
      amount = result[:amount]
      
      if user
        user.increment!(:credits, amount)
        Spending.create!(user: user, amount: amount, description: "Credits Added", transactional_id: transaction_id)
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
