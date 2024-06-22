class AddChallengeToPublicRecords < ActiveRecord::Migration[6.1]
  def change
    add_column :public_records, :challenge, :boolean, default: false
    add_column :public_records, :reason, :string
  end
end
