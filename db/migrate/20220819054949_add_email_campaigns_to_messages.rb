class AddEmailCampaignsToMessages < ActiveRecord::Migration[6.1]
  def change
    add_column :messages, :email_campaign_id, :string
  end
end
