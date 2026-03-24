class AddRepoOwnerToStarEvents < ActiveRecord::Migration[8.0]
  def change
    add_column :star_events, :repo_owner, :string
    add_index :star_events, :repo_owner
  end
end
