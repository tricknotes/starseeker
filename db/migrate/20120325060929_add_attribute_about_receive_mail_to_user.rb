class AddAttributeAboutReceiveMailToUser < ActiveRecord::Migration
  def change
    add_column :users, :receive_mail, :boolean, :default => true
  end
end
