class AddValidationOnUserTable < ActiveRecord::Migration[6.1]
  def change
    change_column_default :users, :free_attack, from: nil, to: 0
  end
end
