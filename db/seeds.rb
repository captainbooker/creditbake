# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password') if Rails.env.development?

# db/seeds.rb

# Clear existing data
User.destroy_all
Account.destroy_all
BureauDetail.destroy_all
Inquiry.destroy_all

# Create Users
user1 = User.create!(
  email: 'user1@example.com',
  password: 'password'
)

user2 = User.create!(
  email: 'user2@example.com',
  password: 'password'
)

# Create Accounts
account1 = Account.create!(
  user: user1,
  account_number: '123456789',
  status: 'Open',
  open_date: Date.new(2024, 3, 22),
  last_activity: Date.new(2024, 4, 1),
  type: 'Credit Card',
  responsibility: 'Individual',
  high_balance: 396.00,
  credit_limit: 400.00,
  monthly_payment: 30.00,
  current_payment_status: 'As Agreed',
  amount_past_due: 0
)

account2 = Account.create!(
  user: user1,
  account_number: '987654321',
  status: 'Open',
  open_date: Date.new(2024, 1, 15),
  last_activity: Date.new(2024, 2, 20),
  type: 'Auto Loan',
  responsibility: 'Joint',
  high_balance: 12000.00,
  credit_limit: 15000.00,
  monthly_payment: 300.00,
  current_payment_status: 'As Agreed',
  amount_past_due: 0
)

account3 = Account.create!(
  user: user1,
  account_number: '987654321',
  status: 'Open',
  open_date: Date.new(2024, 1, 15),
  last_activity: Date.new(2024, 2, 20),
  type: 'Auto Loan',
  responsibility: 'Joint',
  high_balance: 12000.00,
  credit_limit: 15000.00,
  monthly_payment: 300.00,
  current_payment_status: 'As Agreed',
  amount_past_due: 0
)

account4 = Account.create!(
  user: user1,
  account_number: '987654321',
  status: 'Open',
  open_date: Date.new(2024, 1, 15),
  last_activity: Date.new(2024, 2, 20),
  type: 'Auto Loan',
  responsibility: 'Joint',
  high_balance: 12000.00,
  credit_limit: 15000.00,
  monthly_payment: 300.00,
  current_payment_status: 'As Agreed',
  amount_past_due: 0
)

account5 = Account.create!(
  user: user1,
  account_number: '987654321',
  status: 'Open',
  open_date: Date.new(2024, 1, 15),
  last_activity: Date.new(2024, 2, 20),
  type: 'Auto Loan',
  responsibility: 'Joint',
  high_balance: 12000.00,
  credit_limit: 15000.00,
  monthly_payment: 300.00,
  current_payment_status: 'As Agreed',
  amount_past_due: 0
)

# Create Bureau Details
BureauDetail.create!(
  account: account1,
  bureau: 'TransUnion',
  balance: 380.00,
  payment_history: 'OK',
  remarks: 'This Is An Account In Good Standing',
  times_late_30: 0,
  times_late_60: 0,
  times_late_90: 0,
  months_reviewed: 2
)

BureauDetail.create!(
  account: account1,
  bureau: 'Equifax',
  balance: 380.00,
  payment_history: 'OK',
  remarks: 'This Is An Account In Good Standing',
  times_late_30: 0,
  times_late_60: 0,
  times_late_90: 0,
  months_reviewed: 2
)

BureauDetail.create!(
  account: account1,
  bureau: 'Experian',
  balance: 380.00,
  payment_history: 'OK',
  remarks: 'This Is An Account In Good Standing',
  times_late_30: 0,
  times_late_60: 0,
  times_late_90: 0,
  months_reviewed: 2
)

BureauDetail.create!(
  account: account2,
  bureau: 'TransUnion',
  balance: 380.00,
  payment_history: 'OK',
  remarks: 'This Is An Account In Good Standing',
  times_late_30: 0,
  times_late_60: 0,
  times_late_90: 0,
  months_reviewed: 2
)

BureauDetail.create!(
  account: account2,
  bureau: 'Equifax',
  balance: 380.00,
  payment_history: 'OK',
  remarks: 'This Is An Account In Good Standing',
  times_late_30: 0,
  times_late_60: 0,
  times_late_90: 0,
  months_reviewed: 2
)

BureauDetail.create!(
  account: account2,
  bureau: 'Experian',
  balance: 380.00,
  payment_history: 'OK',
  remarks: 'This Is An Account In Good Standing',
  times_late_30: 0,
  times_late_60: 0,
  times_late_90: 0,
  months_reviewed: 2
)

BureauDetail.create!(
  account: account3,
  bureau: 'TransUnion',
  balance: 380.00,
  payment_history: 'OK',
  remarks: 'This Is An Account In Good Standing',
  times_late_30: 0,
  times_late_60: 0,
  times_late_90: 0,
  months_reviewed: 2
)

BureauDetail.create!(
  account: account3,
  bureau: 'Equifax',
  balance: 380.00,
  payment_history: 'OK',
  remarks: 'This Is An Account In Good Standing',
  times_late_30: 0,
  times_late_60: 0,
  times_late_90: 0,
  months_reviewed: 2
)

BureauDetail.create!(
  account: account3,
  bureau: 'Experian',
  balance: 380.00,
  payment_history: 'OK',
  remarks: 'This Is An Account In Good Standing',
  times_late_30: 0,
  times_late_60: 0,
  times_late_90: 0,
  months_reviewed: 2
)

BureauDetail.create!(
  account: account4,
  bureau: 'TransUnion',
  balance: 380.00,
  payment_history: 'OK',
  remarks: 'This Is An Account In Good Standing',
  times_late_30: 0,
  times_late_60: 0,
  times_late_90: 0,
  months_reviewed: 2
)

BureauDetail.create!(
  account: account4,
  bureau: 'Equifax',
  balance: 380.00,
  payment_history: 'OK',
  remarks: 'This Is An Account In Good Standing',
  times_late_30: 0,
  times_late_60: 0,
  times_late_90: 0,
  months_reviewed: 2
)

BureauDetail.create!(
  account: account4,
  bureau: 'Experian',
  balance: 380.00,
  payment_history: 'OK',
  remarks: 'This Is An Account In Good Standing',
  times_late_30: 0,
  times_late_60: 0,
  times_late_90: 0,
  months_reviewed: 2
)

BureauDetail.create!(
  account: account5,
  bureau: 'TransUnion',
  balance: 380.00,
  payment_history: 'OK',
  remarks: 'This Is An Account In Good Standing',
  times_late_30: 0,
  times_late_60: 0,
  times_late_90: 0,
  months_reviewed: 2
)

BureauDetail.create!(
  account: account5,
  bureau: 'Equifax',
  balance: 380.00,
  payment_history: 'OK',
  remarks: 'This Is An Account In Good Standing',
  times_late_30: 0,
  times_late_60: 0,
  times_late_90: 0,
  months_reviewed: 2
)

BureauDetail.create!(
  account: account5,
  bureau: 'Experian',
  balance: 380.00,
  payment_history: 'OK',
  remarks: 'This Is An Account In Good Standing',
  times_late_30: 0,
  times_late_60: 0,
  times_late_90: 0,
  months_reviewed: 2
)


# Create Inquiries
Inquiry.create!(
  user: user1,
  inquiry_name: 'ALLY FINANCI',
  type_of_business: 'Finance',
  inquiry_date: Date.new(2024, 3, 15),
  address: 'Address 1, City, State, ZIP',
  credit_bureau: 'TransUnion'
)

Inquiry.create!(
  user: user1,
  inquiry_name: 'FIRST PREMIER BANK',
  type_of_business: 'Bank',
  inquiry_date: Date.new(2024, 4, 26),
  address: '601 S MINNESOTA AVE, SIOUX FALLS, SD 57104',
  credit_bureau: 'Equifax'
)

Inquiry.create!(
  user: user1,
  inquiry_name: 'CAR FINANCE',
  type_of_business: 'Auto Loan',
  inquiry_date: Date.new(2024, 1, 20),
  address: 'Address 2, City, State, ZIP',
  credit_bureau: 'Experian'
)

Inquiry.create!(
  user: user1,
  inquiry_name: 'CAR FINANCE',
  type_of_business: 'Auto Loan',
  inquiry_date: Date.new(2024, 1, 20),
  address: 'Address 2, City, State, ZIP',
  credit_bureau: 'Experian'
)

Inquiry.create!(
  user: user1,
  inquiry_name: 'CAR FINANCE',
  type_of_business: 'Auto Loan',
  inquiry_date: Date.new(2024, 1, 20),
  address: 'Address 2, City, State, ZIP',
  credit_bureau: 'Experian'
)

Inquiry.create!(
  user: user1,
  inquiry_name: 'CAR FINANCE',
  type_of_business: 'Auto Loan',
  inquiry_date: Date.new(2024, 1, 20),
  address: 'Address 2, City, State, ZIP',
  credit_bureau: 'Experian'
)

Inquiry.create!(
  user: user1,
  inquiry_name: 'CAR FINANCE',
  type_of_business: 'Auto Loan',
  inquiry_date: Date.new(2024, 1, 20),
  address: 'Address 2, City, State, ZIP',
  credit_bureau: 'Experian'
)

Inquiry.create!(
  user: user1,
  inquiry_name: 'CAR FINANCE',
  type_of_business: 'Auto Loan',
  inquiry_date: Date.new(2024, 1, 20),
  address: 'Address 2, City, State, ZIP',
  credit_bureau: 'Experian'
)

puts 'Seed data loaded successfully!'
