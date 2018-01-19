class RenameColumnUser < ActiveRecord::Migration[4.2]
  def change
    rename_column :users, :receive_mail, :subscribe
  end
end
