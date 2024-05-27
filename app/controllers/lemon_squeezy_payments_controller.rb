# app/controllers/lemon_squeezy_payments_controller.rb
class LemonSqueezyPaymentsController < ApplicationController
  def create
    round = params[:round].to_i
    checkout_session = LemonSqueezy::Checkout.create(
      store_id: ENV["lemon_squeezy_store_id"], # Your store ID
      variant_id: ENV["lemon_squeezy_product_id"], # Your product's variant ID
      custom_price: 1599, # Price in cents,
      product_options: {redirect_url: create_attack_url(round: round, payment_success: "true")}
    )

    render json: { checkout_url: checkout_session['url'] }
  end
end
