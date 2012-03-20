class AddUserToGithubInfo < ActiveRecord::Migration
  def change
    add_column :users, :name,       :string, :default => nil
    add_column :users, :avatar_url, :string, :default => nil

    add_column :authentications, :token, :string
  end
end
