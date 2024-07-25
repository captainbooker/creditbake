# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password') if Rails.env.development?

Subscription.create([
  Subscription.create([
    { name: 'Basic', description: 'Basic subscription plan', price: 120.00, duration: 30, attacks: 10 },
    { name: 'Standard', description: 'Standard subscription plan', price: 220.00, duration: 30, attacks: 25 },
    { name: 'Pro', description: 'Pro subscription plan', price: 390.00, duration: 30, attacks: 50 },
    { name: 'Crush', description: 'Crush subscription plan', price: 520.00, duration: 30, attacks: 75 },
    { name: 'Shark', description: 'Shark subscription plan', price: 680.00, duration: 30, attacks: 100 }
  ])  
]) if Rails.env.development?