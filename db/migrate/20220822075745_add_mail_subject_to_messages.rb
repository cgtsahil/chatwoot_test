class AddMailSubjectToMessages < ActiveRecord::Migration[6.1]
  def change
    add_column :messages, :mail_subject, :string
  end
end
