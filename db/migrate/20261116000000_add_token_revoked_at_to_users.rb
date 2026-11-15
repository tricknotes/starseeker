class AddTokenRevokedAtToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :token_revoked_at, :datetime
  end
end
