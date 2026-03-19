class CreateStarEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :star_events do |t|
      t.string   :actor_login,      null: false
      t.string   :actor_avatar_url
      t.string   :repo_name,        null: false
      t.datetime :starred_at,       null: false
      t.timestamps
    end

    add_index :star_events, :starred_at
    add_index :star_events, :actor_login
    add_index :star_events, [:actor_login, :repo_name], unique: true
  end
end
