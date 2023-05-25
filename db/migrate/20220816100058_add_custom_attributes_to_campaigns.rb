class AddCustomAttributesToCampaigns < ActiveRecord::Migration[6.1]
  def change
    add_column :campaigns, :custom_attributes, :jsonb, default: {}
  end
end
