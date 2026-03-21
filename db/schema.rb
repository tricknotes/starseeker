# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_03_20_000002) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "authentications", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.string "provider", null: false
    t.string "token"
    t.string "uid", null: false
    t.datetime "updated_at", precision: nil
    t.integer "user_id", null: false
  end

  create_table "repositories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description"
    t.string "language"
    t.string "name", null: false
    t.string "owner_avatar_url"
    t.string "owner_login"
    t.integer "stargazers_count"
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_repositories_on_name", unique: true
  end

  create_table "star_events", force: :cascade do |t|
    t.string "actor_avatar_url"
    t.string "actor_login", null: false
    t.datetime "created_at", null: false
    t.string "repo_name", null: false
    t.datetime "starred_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_login", "repo_name"], name: "index_star_events_on_actor_login_and_repo_name", unique: true
    t.index ["actor_login"], name: "index_star_events_on_actor_login"
    t.index ["starred_at"], name: "index_star_events_on_starred_at"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "activation_state"
    t.string "activation_token"
    t.datetime "activation_token_expires_at", precision: nil
    t.string "avatar_url"
    t.datetime "created_at", precision: nil
    t.string "crypted_password"
    t.string "email"
    t.string "feed_token"
    t.string "name"
    t.string "salt"
    t.boolean "subscribe", default: true
    t.datetime "updated_at", precision: nil
    t.string "username", null: false
    t.index ["activation_token"], name: "index_users_on_activation_token"
  end
end
