class AddFeedTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :feed_token, :string
  end
end
