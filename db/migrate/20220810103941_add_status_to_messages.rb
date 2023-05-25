class AddStatusToMessages < ActiveRecord::Migration[6.1]
  def change
    add_column :messages, :mail_status, :string, default: 'unread'
  end
end
