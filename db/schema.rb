# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2024_06_13_170656) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.string "account_number", null: false
    t.string "account_type"
    t.string "account_type_detail"
    t.string "account_status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "challenge", default: false, null: false
    t.bigint "user_id", null: false
    t.string "creditor_name"
    t.index ["user_id"], name: "index_accounts_on_user_id"
  end

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "bureau_details", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.integer "bureau", null: false
    t.string "balance_owed"
    t.string "high_credit"
    t.string "credit_limit"
    t.string "past_due_amount"
    t.string "payment_status"
    t.string "date_opened"
    t.string "date_of_last_payment"
    t.string "last_reported"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["account_id"], name: "index_bureau_details_on_account_id"
  end

  create_table "client_profiles", force: :cascade do |t|
    t.string "first_name"
    t.string "middle_name"
    t.string "last_name"
    t.string "ssn_last4"
    t.string "email"
    t.string "phone"
    t.bigint "client_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["client_id"], name: "index_client_profiles_on_client_id"
  end

  create_table "clients", force: :cascade do |t|
    t.string "name"
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_clients_on_user_id"
  end

  create_table "credit_reports", force: :cascade do |t|
    t.bigint "client_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "user_id"
    t.string "username"
    t.string "password"
    t.string "security_question"
    t.string "service"
    t.index ["client_id"], name: "index_credit_reports_on_client_id"
    t.index ["user_id"], name: "index_credit_reports_on_user_id"
  end

  create_table "disputes", force: :cascade do |t|
    t.bigint "client_id", null: false
    t.bigint "credit_report_id", null: false
    t.string "bureau"
    t.text "account_details"
    t.text "inquiry_details"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "payment_status"
    t.string "account_rating"
    t.string "creditor_type"
    t.string "account_status"
    t.string "balance_owed"
    t.string "date_opened"
    t.string "high_balance"
    t.string "closed_date"
    t.string "account_description"
    t.string "dispute_status"
    t.string "creditor_remarks"
    t.string "payment_amount"
    t.string "last_payment"
    t.string "term_length"
    t.string "past_due_amount"
    t.string "account_type"
    t.boolean "open"
    t.string "payment_frequency"
    t.string "credit_limit"
    t.string "date_of_last_activity"
    t.string "date_reported"
    t.string "last_verified"
    t.string "last_reported_on"
    t.string "address"
    t.string "account_number"
    t.string "inquiry_date"
    t.integer "category", null: false
    t.string "disputable_type", null: false
    t.bigint "disputable_id", null: false
    t.index ["client_id"], name: "index_disputes_on_client_id"
    t.index ["credit_report_id"], name: "index_disputes_on_credit_report_id"
    t.index ["disputable_type", "disputable_id"], name: "index_disputes_on_disputable"
  end

  create_table "inquiries", force: :cascade do |t|
    t.string "inquiry_name", null: false
    t.string "type_of_business"
    t.date "inquiry_date"
    t.string "credit_bureau"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "challenge", default: false, null: false
    t.bigint "user_id", null: false
    t.string "address"
    t.index ["user_id"], name: "index_inquiries_on_user_id"
  end

  create_table "letters", force: :cascade do |t|
    t.string "name"
    t.string "bureau"
    t.text "experian_document"
    t.text "transunion_document"
    t.text "equifax_document"
    t.bigint "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_letters_on_user_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.string "resource_type"
    t.bigint "resource_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["resource_type", "resource_id"], name: "index_roles_on_resource"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "phone_number"
    t.string "first_name"
    t.string "last_name"
    t.string "street_address"
    t.string "city"
    t.string "state"
    t.string "postal_code"
    t.string "country"
    t.string "ssn_last4"
    t.decimal "credits", default: "0.0", null: false
    t.string "encrypted_ssn_last4"
    t.string "encrypted_ssn_last4_iv"
    t.string "ssn_last4_bidx"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "role_id"
    t.index ["role_id"], name: "index_users_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
    t.index ["user_id"], name: "index_users_roles_on_user_id"
  end

  add_foreign_key "accounts", "users"
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "bureau_details", "accounts"
  add_foreign_key "client_profiles", "clients"
  add_foreign_key "clients", "users"
  add_foreign_key "credit_reports", "clients"
  add_foreign_key "credit_reports", "users"
  add_foreign_key "disputes", "clients"
  add_foreign_key "disputes", "credit_reports"
  add_foreign_key "inquiries", "users"
end
