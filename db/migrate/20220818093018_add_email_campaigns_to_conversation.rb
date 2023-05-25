class AddEmailCampaignsToConversation < ActiveRecord::Migration[6.1]
  def change
    add_column :conversations, :email_campaigns, :string, array: true, default: []
  end
end
