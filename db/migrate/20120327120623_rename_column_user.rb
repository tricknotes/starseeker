class RenameColumnUser < ActiveRecord::Migration
  def change
    rename_column :users, :receive_mail, :subscribe
  end
end
