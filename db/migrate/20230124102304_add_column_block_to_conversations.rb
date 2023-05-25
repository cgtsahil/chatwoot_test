class AddColumnBlockToConversations < ActiveRecord::Migration[6.1]
  def change
    add_column :conversations, :blocked, :boolean, default: false
  end
end
