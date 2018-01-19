class AddAttributeAboutReceiveMailToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :receive_mail, :boolean, :default => true
  end
end
