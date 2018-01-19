class AddPasswordColumnToUsers < ActiveRecord::Migration[4.2]
  def down
    remove_column :users, :crypted_password
    remove_column :users, :salt
  end

  def up
    add_column :users, :crypted_password, :string, default: nil
    add_column :users, :salt,             :string, default: nil
  end
end
