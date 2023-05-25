class AddMailMessageIdToMessages < ActiveRecord::Migration[6.1]
  def change
    add_column :messages, :mail_message_id, :string
  end
end
