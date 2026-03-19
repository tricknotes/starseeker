class CreateRepositories < ActiveRecord::Migration[8.0]
  def change
    create_table :repositories do |t|
      t.string  :name,              null: false
      t.string  :description
      t.string  :language
      t.integer :stargazers_count
      t.string  :owner_login
      t.string  :owner_avatar_url
      t.timestamps
    end

    add_index :repositories, :name, unique: true
  end
end
