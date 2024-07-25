class AddEmailToClientInvites < ActiveRecord::Migration[6.1]
  def change
    add_column :client_invites, :email, :string, null: false
  end
end
