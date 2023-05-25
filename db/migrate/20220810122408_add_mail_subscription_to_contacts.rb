class AddMailSubscriptionToContacts < ActiveRecord::Migration[6.1]
  def change
    add_column :contacts, :mail_subscription, :string, default: 'subscribed'
  end
end
