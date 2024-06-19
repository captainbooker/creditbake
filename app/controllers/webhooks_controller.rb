class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def authorize_net
    # Parse the JSON payload
    payload = params

    # Extract user_id and amount from the payload
    user_id = payload.dig("USER_ID", "value")
    amount = payload.dig("Total", "value").to_f

    # Find the user
    user = User.find_by(id: user_id)

    if user
      # Create a new Spending record
      spending = user.spendings.create!(
        amount: amount,
        description: 'Authorize.Net Transaction'
      )

      # Update the user's credits (assuming the User model has a credits attribute)
      user.update!(credits: user.credits + amount)

      render json: { message: 'Spending record created and credits updated' }, status: :ok
    else
      render json: { error: 'User not found' }, status: :not_found
    end
  rescue JSON::ParserError => e
    render json: { error: 'Invalid JSON payload' }, status: :unprocessable_entity
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
  end
end
