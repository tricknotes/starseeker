class AddFeedTokenToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :feed_token, :string
  end
end
