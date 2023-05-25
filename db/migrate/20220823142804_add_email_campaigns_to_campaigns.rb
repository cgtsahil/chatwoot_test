class AddEmailCampaignsToCampaigns < ActiveRecord::Migration[6.1]
  def change
    add_column :contacts, :email_campaigns, :string, array: true, default: []
  end
end
