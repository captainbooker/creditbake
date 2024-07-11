class AddUserReferencesToClients < ActiveRecord::Migration[6.1]
  def change
    add_reference :inquiries, :client, foreign_key: true
    add_reference :accounts, :client, foreign_key: true
    add_reference :letters, :client, foreign_key: true
    add_reference :spendings, :client, foreign_key: true
    add_reference :mailings, :client, foreign_key: true
    add_reference :public_records, :client, foreign_key: true
    add_reference :personal_informations, :client, foreign_key: true
  end
end
