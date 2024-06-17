class AddAgreementToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :agreement, :boolean
  end
end
