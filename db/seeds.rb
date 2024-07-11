# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password') if Rails.env.development?

Subscription.create([
  { name: 'Starter', description: 'Basic subscription plan', price: 120.00, duration: 30 },
  { name: 'Crush', description: 'Crush subscription plan', price: 350.00, duration: 30 },
  { name: 'Shark', description: 'Shark subscription plan', price: 600.00, duration: 30 }
]) if Rails.env.development?